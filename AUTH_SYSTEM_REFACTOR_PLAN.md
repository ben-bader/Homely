# Homely Authentication System - Comprehensive Refactor Plan

**Date:** June 3, 2026  
**Scope:** Complete authentication system redesign for mobile-first architecture  
**Status:** In Progress

---

## EXECUTIVE SUMMARY

The current authentication system mixes web and mobile concerns, creating inconsistent flows and maintenance burden. This refactor consolidates to a **mobile-first architecture** with:

- Email verification via clickable links (preserved)
- Password reset via OTP codes (new)
- Standardized API responses (new)
- Production-ready security (new)
- Clean separation of concerns (new)

---

## CURRENT PROBLEMS

### 1. Password Reset Architecture Issues
- **Problem**: URL-based tokens in emails create friction
- **Evidence**: Links like `https://ngrok/.../reset-password?token=XXX&email=YYY`
- **Impact**: 
  - Deep-link conflicts with Flutter mobile
  - Backend renders HTML pages (not scalable)
  - No brute-force protection
  - Tokens are long and not user-friendly

### 2. Type Casting Errors in Flutter
- **Problem**: `type 'String' is not a subtype of type 'Map<String, dynamic>'`
- **Root Cause**: Backend returns plain strings for some endpoints while Flutter expects JSON maps
- **Evidence**: Password reset endpoints returning `ResponseEntity.ok(Map.of(...))`
- **Impact**: Crashes when parsing API responses

### 3. Mixed Architecture Concerns
- **Problem**: Backend serves HTML pages AND API endpoints
- **Root Cause**: No clear separation between web flows and mobile flows
- **Impact**: 
  - Difficult to maintain
  - Inconsistent error handling
  - No standardized response format

### 4. Security Gaps
- No rate limiting on auth endpoints
- No brute-force protection
- Weak password validation
- No audit logging
- JWT expiration not enforced consistently
- Refresh token rotation not properly validated

### 5. Email System Limitations
- Plain HTML templates (not reusable)
- No OTP support
- Links are complex and fragile

---

## TARGET ARCHITECTURE

### Mobile-First Principle
- **Primary Client**: Flutter mobile app
- **No Web UI**: Removed
- **Backend**: API-only Spring Boot service
- **Email**: Transactional notifications only

### Authentication Flow

```
┌─────────────┐
│   Flutter   │
└──────┬──────┘
       │
       ├─→ POST /register  (create account)
       │   └─→ Verification email sent
       │
       ├─→ GET verify-email (click email link)
       │   └─→ HTML success page in browser
       │
       ├─→ POST /login  (authenticate)
       │
       ├─→ POST /request-password-reset  (forgot password)
       │   └─→ OTP code sent via email
       │
       └─→ POST /reset-password  (with OTP code)
           └─→ Success
```

---

## IMPLEMENTATION PLAN

### Phase 1: Database Changes
- [x] Add `reset_code` field to User entity
- [x] Add `reset_code_expiry` field to User entity
- [x] Remove deprecated `resetToken` and `resetTokenExpiry`
- [x] Create Flyway migration script

### Phase 2: Backend Refactoring

#### 2.1 API Response Standardization
- [ ] Create `ApiResponse<T>` wrapper class
- [ ] Update all auth endpoints to return `ApiResponse`
- [ ] Standardize error responses

#### 2.2 Password Reset System
- [ ] Refactor `AuthService.requestPasswordReset()`
  - Generate 6-digit OTP code
  - Set 15-minute expiration
  - Save to database
- [ ] Refactor `AuthService.resetPassword()`
  - Accept email + code + newPassword
  - Validate code against database
  - Validate expiration
  - Update password
  - Clear code/expiration

#### 2.3 Email Service
- [ ] Refactor `EmailService` to use MimeMessage
- [ ] Create `sendVerificationEmail()` method
- [ ] Create `sendPasswordResetCodeEmail()` method
- [ ] Add HTML email templates
- [ ] Brand with Homely logo and colors

#### 2.4 Controllers
- [ ] Remove `GET /api/auth/reset-password` endpoint
- [ ] Update `POST /api/auth/request-password-reset` to return OTP
- [ ] Update `POST /api/auth/reset-password` to accept OTP
- [ ] Add proper request/response validation
- [ ] Add rate limiting decorators

#### 2.5 Security Enhancements
- [ ] Add rate limiting (login: 5/min, register: 3/hour, reset: 3/hour)
- [ ] Add brute-force protection (account lockout after 5 failed attempts)
- [ ] Add audit logging for auth events
- [ ] Validate JWT expiration
- [ ] Validate refresh token rotation
- [ ] Add CORS hardening
- [ ] Add request validation

#### 2.6 DTOs and Entities
- [ ] Create `PasswordResetCodeRequest` DTO
- [ ] Create `PasswordResetConfirmRequest` DTO  
- [ ] Create `ApiResponse<T>` wrapper
- [ ] Update User entity

### Phase 3: Flutter Refactoring

#### 3.1 Fix API Contracts
- [ ] Update `auth_remote_datasource.dart`
  - Fix `requestPasswordReset()` to handle new response
  - Fix `resetPassword()` to accept email + code + password
- [ ] Fix response parsing in `api_client.dart`
- [ ] Ensure all endpoints return JSON maps

#### 3.2 UI Screens
- [ ] Update `reset_password_screen.dart`
  - Add OTP code input field
  - Add email field
  - Add new password field
  - Remove token/deep-link logic
- [ ] Keep `email_verification_screen.dart` (no changes needed)
- [ ] Remove any deep-link reset logic from `main.dart`

#### 3.3 Repository Updates
- [ ] Update `auth_repository_impl.dart`
  - Update `requestPasswordReset()` signature
  - Update `resetPassword()` signature

### Phase 4: Testing & Validation
- [ ] End-to-end registration flow
- [ ] Email verification via link
- [ ] Password reset via OTP
- [ ] Security validation (rate limiting, brute-force)
- [ ] Error handling
- [ ] JWT refresh flow

---

## FILES TO MODIFY

### Backend
```
src/main/java/com/homely/auth/controller/AuthController.java
src/main/java/com/homely/auth/service/AuthService.java
src/main/java/com/homely/auth/dto/PasswordResetSubmitRequest.java
src/main/java/com/homely/auth/dto/PasswordResetRequest.java
src/main/java/com/homely/common/service/EmailService.java
src/main/java/com/homely/user/entity/User.java
src/main/java/com/homely/user/repository/UserRepository.java
src/main/java/com/homely/config/SecurityConfig.java
```

### New Backend Files
```
src/main/java/com/homely/auth/dto/ApiResponse.java
src/main/java/com/homely/auth/dto/PasswordResetCodeRequest.java
src/main/java/com/homely/auth/dto/PasswordResetConfirmRequest.java
src/main/java/com/homely/common/security/RateLimitingAspect.java
src/main/java/com/homely/common/security/BruteForceProtection.java
src/main/java/com/homely/common/audit/AuditLogger.java
src/main/resources/db/migration/V5__refactor_password_reset_to_otp.sql
```

### Flutter
```
lib/data/datasources/remote/auth_remote_datasource.dart
lib/data/repositories/auth_repository_impl.dart
lib/domain/repositories/i_auth_repository.dart
lib/ui/screens/auth/reset_password_screen.dart
lib/main.dart (remove reset-password deep link handling)
```

### Files to DELETE
```
None - all functionality preserved, just refactored
```

---

## FILES TO DELETE

None. All functionality is preserved and refactored, not removed.

---

## MIGRATION STRATEGY

### Database Migration (V5)
```sql
-- Add new fields
ALTER TABLE users ADD COLUMN reset_code VARCHAR(6);
ALTER TABLE users ADD COLUMN reset_code_expiry TIMESTAMP;

-- Migrate existing reset tokens (mark expired)
UPDATE users SET reset_code_expiry = CURRENT_TIMESTAMP 
WHERE reset_code_expiry IS NULL AND reset_token IS NOT NULL;

-- Drop old fields (later, after verification)
-- ALTER TABLE users DROP COLUMN reset_token;
-- ALTER TABLE users DROP COLUMN reset_token_expiry;
```

### Backward Compatibility
- Existing reset tokens can coexist with new OTP system
- Gradual migration of users during normal password reset flow
- No data loss

---

## SECURITY IMPROVEMENTS

### Rate Limiting
```
POST /api/auth/login:          5 requests per minute per IP
POST /api/auth/register:       3 requests per hour per IP
POST /api/auth/request-password-reset: 3 requests per hour per email
POST /api/auth/reset-password: 5 requests per hour per email
```

### Brute-Force Protection
```
- Failed login attempts: lock account after 5 failures
- Duration: 15 minutes
- Log all suspicious activity
```

### Audit Logging
```
- All auth events logged (register, login, logout, verify, reset)
- Include: timestamp, email, IP, user agent, success/failure
- Retention: 90 days
```

### JWT Security
```
- Access token expiration: 24 hours (configurable)
- Refresh token expiration: 30 days
- Refresh token rotation: new token on each refresh
- Token blacklist on logout
```

---

## API CONTRACT DOCUMENTATION

### POST /api/auth/request-password-reset

**Request:**
```json
{
  "email": "user@example.com"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Password reset code sent to your email",
  "data": null
}
```

**Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "User not found",
  "data": null
}
```

### POST /api/auth/reset-password

**Request:**
```json
{
  "email": "user@example.com",
  "code": "483921",
  "newPassword": "SecurePassword123!"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Password reset successfully",
  "data": null
}
```

**Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "Invalid or expired reset code",
  "data": null
}
```

---

## PRODUCTION READINESS CHECKLIST

- [ ] All endpoints return standardized `ApiResponse` format
- [ ] All error messages are user-friendly
- [ ] Rate limiting configured and tested
- [ ] Brute-force protection configured and tested
- [ ] Audit logging configured and tested
- [ ] Email templates branded and tested
- [ ] OTP code format defined (6 digits)
- [ ] OTP expiration set (15 minutes)
- [ ] Database migration tested
- [ ] Flutter app updated and tested
- [ ] End-to-end flows tested
- [ ] Security audit completed
- [ ] Load testing completed
- [ ] Error handling comprehensive
- [ ] Logging configured for production
- [ ] Documentation updated
- [ ] Team trained on new system

---

## ROLLBACK PLAN

If issues arise:
1. Keep both old and new password reset systems running
2. Serve OTP via email but accept both OTP and old tokens
3. Gradually deprecate old token system
4. Database fields are backward compatible

---

## TIMELINE

- **Phase 1 (Database):** 1 hour
- **Phase 2 (Backend):** 4-6 hours
- **Phase 3 (Flutter):** 2-3 hours
- **Phase 4 (Testing):** 2-3 hours
- **Total:** 9-13 hours

---

## SUCCESS METRICS

- ✓ Zero type casting errors in Flutter
- ✓ All API endpoints return standardized responses
- ✓ Password reset works end-to-end via OTP
- ✓ Email verification preserved and working
- ✓ Rate limiting prevents abuse
- ✓ Audit logs track all auth events
- ✓ No 401/403 errors for public endpoints
- ✓ Smooth user experience on mobile

---

## SIGN-OFF

- **Architect:** GitHub Copilot
- **Date:** June 3, 2026
- **Status:** Ready for Implementation

