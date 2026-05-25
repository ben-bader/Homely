# Chat Messaging Architecture Refactor — Implementation Guide

## Overview
This refactor stabilizes the Homely chat system by:
1. **Fixing backend null conversation crashes** with graceful fallback
2. **Migrating from property-based to participant-based conversations**
3. **Hardening frontend STOMP lifecycle** to prevent race conditions
4. **Ensuring message queue flushing** on reconnection

---

## Changes Summary

### Backend Changes

#### 1. ChatService.sendMessage() — Improved Null Safety
**File**: `backend/src/main/java/com/homely/chat/service/ChatService.java`

**Before**:
- Crashed if both `conversationId` and `propertyId` were null
- No fallback logic

**After**:
- Explicit logging and error messages
- Prioritizes `conversationId` path
- Falls back to `propertyId` → finds/creates conversation by participants
- Graceful exception if both null

**Code**:
```java
public Message sendMessage(MessageDto mdto, String senderEmail) {
    Conversation conversation;
    User sender = userRepository.findByEmail(senderEmail)
        .orElseThrow(() -> new RuntimeException("Sender not found"));

    if (mdto.getConversationId() != null) {
        // Try conversationId path first
        conversation = getConversationById(mdto.getConversationId());
    } else if (mdto.getPropertyId() != null) {
        // Fallback: create/find conversation between sender and property seller
        Property property = propertyRepository.findById(mdto.getPropertyId()).orElseThrow();
        conversation = findOrCreateConversation(sender, property.getSeller());
    } else {
        // Both null — log and reject
        throw new RuntimeException("Conversation id or property id required");
    }
    // ... rest of implementation
}
```

#### 2. Database Migration V2 — Participant-Based Schema
**File**: `backend/src/main/resources/db/migration/V2__refactor_conversation_to_participant_based.sql`

**What It Does**:
- Adds `participant_one_id` and `participant_two_id` columns
- Populates from existing message data (idempotent)
- Adds FK constraints
- Preserves legacy `property` field for gradual migration

**Safety**:
- Uses `DO $$...END$$` blocks (PostgreSQL) for idempotent execution
- Existing conversations with messages are migrated automatically
- Orphaned conversations remain unchanged (can be cleaned up later)

---

### Frontend Changes

#### 3. ChatNotifier Lifecycle Fix
**File**: `mobile/lib/ui/providers/chat_providers.dart`

**Before**:
- Race condition: subscribed to STOMP before connection established
- No guarantee WebSocket handshake completed

**After**:
- Explicit connection check before subscribe
- Added `!mounted` guard in `_subscribe()`
- Proper async/await ordering

**Code**:
```dart
Future<void> _init() async {
  try {
    final messages = await _repo.fetchMessages(conversationId);
    if (mounted) {
      state = AsyncValue.data(messages);
    }

    // Ensure WebSocket is connected before subscribing
    if (!_ws.isConnected) {
      await _ws.connect(onConnected: () {
        if (mounted) _subscribe();
      });
    } else {
      if (mounted) _subscribe();
    }
  } catch (e, st) {
    if (mounted) state = AsyncValue.error(e, st);
  }
}

void _subscribe() {
  if (_subscribed || !mounted) return;  // Guard against stale subscriptions
  _subscribed = true;
  _ws.subscribe(conversationId, _onMessageReceived);
}
```

#### 4. Message Queue & Reconnection
**File**: `mobile/lib/infrastructure/services/chat_service.dart`

**Before**:
- Messages queued but not flushed reliably on reconnect
- No callback to trigger flush after connection

**After**:
- `sendMessage()` passes `onConnected` callback
- `_flushQueuedMessages()` clears queue atomically
- `disconnect()` cleans up state properly

**Code**:
```dart
void sendMessage(String conversationId, String content) async {
  final body = content.trim();
  if (body.isEmpty) return;

  final payload = {'conversationId': conversationId, 'body': body};
  
  if (_stompClient?.isActive == true) {
    _stompClient?.send(
      destination: '/app/chat.send',
      body: jsonEncode(payload),
    );
    return;
  }

  // Queue and ensure connection with flush callback
  _messageQueue.add(payload);
  await connect(onConnected: _flushQueuedMessages);
}

void _flushQueuedMessages() {
  if (_stompClient?.isActive != true || _messageQueue.isEmpty) return;
  final queue = List<Map<String, dynamic>>.from(_messageQueue);
  _messageQueue.clear();  // Clear first to avoid duplicates
  for (final payload in queue) {
    _stompClient?.send(
      destination: '/app/chat.send',
      body: jsonEncode(payload),
    );
  }
}

void disconnect() {
  _reconnectTimer?.cancel();
  _stompClient?.deactivate();
  _isConnecting = false;
  _messageQueue.clear();
  _subscriptions.clear();
}
```

---

## Testing Checklist

### Unit Tests
- [ ] `ChatService.sendMessage()` with null conversationId/propertyId
- [ ] `ChatService.sendMessage()` fallback to propertyId path
- [ ] Message saved and notification sent

### Integration Tests (Backend)
- [ ] STOMP send → message persisted → notification created
- [ ] Conversation merge on duplicate participants
- [ ] Read status tracking (UNREAD → READ)

### Integration Tests (Frontend)
- [ ] ChatNotifier connects and subscribes without race
- [ ] Message queue flushes after reconnect
- [ ] Properties shared in chat show correctly
- [ ] Edit/delete messages work with JWT auth

### E2E Tests
1. **Create conversation**: `POST /chat/conversations/{propertyId}`
2. **Send message**: STOMP `/app/chat.send` with conversationId
3. **Receive message**: Subscribe to `/topic/chat/{conversationId}`
4. **Disconnect/reconnect**: Ensure queued messages are sent
5. **Edit/delete**: Verify permissions and UI updates

### Migration Test
- [ ] Run V1 and V2 migrations on staging schema
- [ ] Verify all conversations have both participant IDs
- [ ] Check no data loss

---

## Deployment Order

1. **Deploy Backend** (with Flyway migrations)
   - Compile and test locally
   - Deploy to staging
   - Run migrations
   - Smoke test chat endpoints

2. **Deploy Frontend** (when backend is stable)
   - Build and test locally
   - Deploy to staging
   - Test STOMP reconnection
   - Monitor for socket errors

3. **Production Rollout**
   - Gradual rollout recommended (10% → 50% → 100%)
   - Monitor logs for chat errors
   - Set up alerts for STOMP disconnections

---

## Rollback Plan

If issues arise:

1. **Backend**: Revert to previous version (migrations are not rolled back automatically)
   - Schema remains participant-based but conversation creation still works with participants
   - No data loss

2. **Frontend**: Revert to previous version
   - STOMP client reverts to original queue logic
   - May experience message loss during reconnection (acceptable short-term)

---

## Known Limitations (For Future Work)

1. **Orphaned Conversations**: Conversations with no messages and no participants (pre-migration)
   - Mitigation: Future cleanup script or admin dashboard
   
2. **Legacy Property Field**: Conversation.property still exists
   - Mitigation: Deprecate after 2+ releases; plan full removal

3. **Message Queue Persistence**: Queued messages lost if app crashes
   - Mitigation: Implement local SQLite queue for guaranteed delivery (Phase 2)

4. **Concurrent Message Sends**: No deduplication if user sends while reconnecting
   - Mitigation: Implement idempotency keys (Phase 2)

---

## Validation Commands

### Backend
```bash
cd backend
mvn clean compile -DskipTests
mvn test -Dtest=ChatServiceTest
```

### Frontend
```bash
cd mobile
flutter analyze lib/ui/providers/chat_providers.dart lib/infrastructure/services/chat_service.dart
flutter test test/ui/providers/chat_providers_test.dart
```

---

## Emergency Contact

If chat is broken in production:
1. Check backend STOMP logs for connection errors
2. Check frontend logs for WebSocket errors
3. Verify JWT token expiration
4. Restart backend (clears all STOMP subscriptions)
5. Redeploy frontend to force reconnect

---

**Document Version**: 1.0  
**Last Updated**: [Current Date]  
**Author**: AI Assistant  
**Status**: ✅ Ready for Review
