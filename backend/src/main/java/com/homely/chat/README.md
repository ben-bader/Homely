Absolutely 👍
Below is a **clear, frontend-friendly README** you can hand directly to the **Flutter developer**.
It explains **what the chat is**, **how it works**, and **exactly what they need to do step by step**, without backend noise.

You can copy-paste this into `README_CHAT.md`.

---

# 🏠 Real Estate Chat – Frontend (Flutter) Guide

This document explains how to integrate the **property-based chat system** into the Flutter app.

The chat allows a **client (buyer)** to communicate **directly with the seller** about a **specific property**.

---

## 1️⃣ Concept Overview (Very Important)

### What kind of chat is this?

* ❌ NOT a global chat
* ❌ NOT user-to-user free chat
* ✅ A **private chat linked to a property**

### Core rules

* A chat exists **per property**
* Only **buyer & seller** can see messages
* One conversation per **(property, buyer)**
* Chat starts from the **property details page**

---

## 2️⃣ High-Level Flow (Frontend Perspective)

```
Property Page
   ↓
"Chat with seller" button
   ↓
REST API → Get/Create Conversation
   ↓
Open Chat Screen
   ↓
WebSocket (STOMP)
   ↓
Send & Receive Messages
```

---

## 3️⃣ Authentication Requirement

⚠️ **WebSocket uses JWT authentication**

The same JWT used for REST APIs **must be sent when opening the WebSocket connection**.

---

## 4️⃣ Required Flutter Packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  stomp_dart_client: ^1.0.0
  dio: ^5.0.0
```

---

## 5️⃣ Step 1: Start or Get a Conversation (REST)

### When?

When user clicks **“Chat with seller”** on the property page.

### API Call

```
POST /api/conversations/property/{propertyId}
```

### Flutter Example

```dart
final response = await dio.post(
  '/api/chat/conversations/property/$propertyId',
  options: Options(
    headers: {
      'Authorization': 'Bearer $jwtToken',
    },
  ),
);

final conversationId = response.data['id'];
```

📌 Save `conversationId` – everything depends on it.

---

## 6️⃣ Step 2: Open WebSocket Connection

### WebSocket URL

```
http://YOUR_DOMAIN/ws-chat
```

### Create STOMP Client

```dart
final stompClient = StompClient(
  config: StompConfig.sockJS(
    url: 'http://YOUR_DOMAIN/ws-chat',
    stompConnectHeaders: {
      'Authorization': 'Bearer $jwtToken',
    },
    webSocketConnectHeaders: {
      'Authorization': 'Bearer $jwtToken',
    },
    onConnect: onConnect,
  ),
);

stompClient.activate();
```

---

## 7️⃣ Step 3: Subscribe to the Conversation

Each conversation has **its own private channel**.

### Subscription Destination

```
/user/queue/conversations/{conversationId}
```

### Flutter Example

```dart
void onConnect(StompFrame frame) {
  stompClient.subscribe(
    destination: '/user/queue/conversations/$conversationId',
    callback: (frame) {
      final message = jsonDecode(frame.body!);
      print(message['body']);
    },
  );
}
```

📌 Messages received here are **real-time** and **private**.

---

## 8️⃣ Step 4: Send a Message

### Destination

```
/app/chat.send
```

### Message Payload

```json
{
  "conversationId": "UUID",
  "content": "Message text"
}
```

### Flutter Example

```dart
stompClient.send(
  destination: '/app/chat.send',
  body: jsonEncode({
    'conversationId': conversationId,
    'body': 'Is this property still available?',
  }),
);
```

---

## 9️⃣ Message Structure (Received from Backend)

```json
// example 
{
  "id": "Long",
  "body": "Hello!",
  "sender": {
    "id": "UUID",
    "username": "seller123"
  },
  "attachments":{
    "type" : "IMAGE",
    "url" : "https://storage.homely.com/messages/image-12345.png"
  }
}
```

Use this to:

* Align messages left/right
* Show sender name
* Show timestamp

---

## 🔟 UI Recommendations (Best Practices)

### Chat Screen

* Show **property info** at top (title / image)
* Bubble alignment:

  * Buyer → right
  * Seller → left
* Disable send button if WebSocket disconnected

### Navigation

* Property Page → Chat Screen
* Chat List Page (future):

  * One row per conversation
  * Show last message + property title

---

## 1️⃣1️⃣ Important Rules (Frontend Must Respect)

✅ Always call REST API before WebSocket
✅ Never guess conversationId
✅ Do NOT allow chat without login
✅ One WebSocket connection per user session
❌ Do NOT expose sellerId manually
❌ Do NOT create custom destinations

---

## 1️⃣2️⃣ Error Scenarios to Handle

* 🔴 JWT expired → redirect to login
* 🔴 WebSocket disconnect → retry connection
* 🔴 No internet → show offline state
* 🔴 Empty message → disable send

---

## 1️⃣3️⃣ What Frontend Does NOT Handle

🚫 Authorization logic
🚫 Conversation ownership checks
🚫 Message persistence
🚫 Security validation

(All handled by backend)

---

## 1️⃣4️⃣ Summary (TL;DR)

1. User clicks **Chat with seller**
2. Call REST API → get `conversationId`
3. Open WebSocket with JWT
4. Subscribe to `/user/queue/conversations/{conversationId}`
5. Send messages to `/app/chat.send`
6. Receive real-time messages 🎉


