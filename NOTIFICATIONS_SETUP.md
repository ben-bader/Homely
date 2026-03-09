# Push Notifications Implementation Guide

## ✅ Backend Changes Completed

### 1. **Added Firebase Admin SDK**
   - Added `firebase-admin:9.2.0` dependency to `pom.xml`
   - Created `FirebaseConfig.java` to initialize Firebase
   - Created `FirebaseMessagingService.java` to send push notifications

### 2. **Updated User Entity**
   - Added `fcmToken` field to store Firebase Cloud Messaging tokens

### 3. **Updated User Service**
   - Added `updateFcmToken(UUID id, String token)` method to save device tokens
   - Added endpoint `/api/users/{id}/fcm-token` to receive tokens from mobile

### 4. **Updated Notification Service**
   - Integrated Firebase messaging - notifications now send push messages
   - Added `_registerDeviceToken()` to register FCM tokens
   - Automatic push notification when new notification is created

## ✅ Mobile Changes Completed

### 1. **Added Firebase Dependencies**
   - Updated `pubspec.yaml` with:
     - `firebase_core: ^2.24.2`
     - `firebase_messaging: ^14.7.10`
     - `firebase_analytics: ^10.8.0`

### 2. **Updated main.dart**
   - Initialized Firebase at app startup
   - Added `firebase_options.dart` with Firebase configuration

### 3. **Enhanced NotificationService**
   - Added Firebase Messaging integration
   - `startPolling()` now registers FCM device token with backend
   - Handles foreground and background messages
   - Handles message taps for navigation
   - Better notification titles for each notification type

## 🔧 Setup Instructions

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project called "homely-notifications"
3. Enable Cloud Messaging (for Android)
4. Enable APNs certificate upload (for iOS)

### Step 2: Download Credentials
1. In Firebase Console, go to Project Settings → Service Accounts
2. Click "Generate new private key"
3. Save the JSON file as `firebase-credentials.json`
4. Place it in `backend/src/main/resources/firebase-credentials.json`

### Step 3: Configure Mobile
1. Download `google-services.json` from Firebase Console
2. Place it in `mobile/android/app/`
3. Update `lib/firebase_options.dart` with your Firebase credentials

### Step 4: Test Notifications

#### Android
```bash
# Build and run the app
cd mobile
flutter pub get
flutter run
```

#### Create a Test Property (triggers notification)
```bash
curl -X POST http://localhost:8082/api/properties \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "Test Property",
    "description": "Test description",
    "price": 100000,
    "location": "Test Location",
    "listingType": "SALE",
    "propertyType": "APARTMENT"
  }'
```

#### Create a Chat Message (triggers notification)
```bash
curl -X POST http://localhost:8082/api/conversations/{conversationId}/messages \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "body": "Hello! Is this property still available?"
  }'
```

#### Check Notifications Via API
```bash
curl http://localhost:8082/api/notifications \
  -H "Authorization: Bearer YOUR_TOKEN"

# Get unread only
curl http://localhost:8082/api/notifications/unread \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 📱 Notification Types Supported

| Type | Title | Triggered By |
|------|-------|--------------|
| `NEW_CHAT_MESSAGE` | 💬 New Message | New chat message sent |
| `CONVERSATION_CREATED` | 💬 New Conversation | Client starts conversation |
| `VISIT_REQUEST_CREATED` | 👁️ Visit Request | Visit request created |
| `VISIT_REQUEST_STATUS_CHANGED` | 👁️ Visit Request Updated | Visit request status changes |
| `PROPERTY_CREATED` | 🏠 New Property | Property listing created |
| `PROPERTY_STATUS_CHANGED` | 🏠 Property Updated | Property status changes |
| `BOOST_PURCHASED` | ⚡ Boost Purchased | Seller purchases boost |
| `BOOST_STATUS_CHANGED` | ⚡ Boost Updated | Boost status changes |
| `FEEDBACK_RECEIVED` | ⭐ New Feedback | Feedback is submitted |

## 🐛 Troubleshooting

### Notifications not received?
1. **Check FCM Token**: Verify user has `fcmToken` in database
   ```sql
   SELECT id, email, fcm_token FROM users WHERE email = 'test@example.com';
   ```

2. **Check Notification Creation**: Verify notifications table has records
   ```sql
   SELECT id, type, user_id, read, created_at FROM notification 
   ORDER BY created_at DESC LIMIT 10;
   ```

3. **Check Firebase Credentials**: Ensure `firebase-credentials.json` is in correct location

4. **Verify Permissions**:
   - Android: Check `android/app/src/main/AndroidManifest.xml` for notification permissions
   - iOS: Configure APNs in Firebase Console

### Firebase Admin SDK Issues?
- If Firebase credentials file is missing, the app will log a warning but continue running
- Push notifications will be disabled without Firebase credentials
- Notifications will still be saved to database and work via polling

## 📊 Notification Flow

```
Mobile App
    ↓
[Init Firebase] → Get FCM Token
    ↓
Register Token → POST /api/users/{id}/fcm-token
    ↓
Backend Store fcmToken in User.fcmToken
    ↓
User Action (create property, send message, etc.)
    ↓
Create Notification → Notification saved to database + FCM message sent
    ↓
Firebase Cloud Messaging → Send to device
    ↓
Mobile App receives push notification → Show local notification
    ↓
Polling (every 15s) → Fetch unread notifications from API
```

## 🔐 Security Notes

- FCM tokens should never be stored in version control
- Firebase credentials must be kept secret
- Ensure only authenticated users can register tokens
- Validate authentication before creating notifications
