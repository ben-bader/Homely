import 'package:flutter/foundation.dart';

class EnvironmentConfig {
  EnvironmentConfig._();

  static const String _debugBaseUrlFromEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _releaseBaseUrlFromEnv = String.fromEnvironment(
    'PRODUCTION_API_BASE_URL',
    defaultValue: '',
  );

  static const String defaultDevBaseUrl = 'https://elegant-jasiah-speedfully.ngrok-free.dev/api';
  // Keep the public tunnel as the default production base URL
  static const String defaultProdBaseUrl =
      'https://elegant-jasiah-speedfully.ngrok-free.dev/api';

  static final EnvironmentConfig instance = EnvironmentConfig._();

  String _overrideBaseUrl = '';

  String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) return _normalizeUrl(_overrideBaseUrl);
    if (kReleaseMode) {
      return _normalizeUrl(
        _releaseBaseUrlFromEnv.isNotEmpty
            ? _releaseBaseUrlFromEnv
            : defaultProdBaseUrl,
      );
    }
    return _normalizeUrl(
      _debugBaseUrlFromEnv.isNotEmpty
          ? _debugBaseUrlFromEnv
          : defaultDevBaseUrl,
    );
  }

  void setOverrideBaseUrl(String url) {
    _overrideBaseUrl = _normalizeUrl(url);
  }

  void clearOverride() {
    _overrideBaseUrl = '';
  }

  static String _normalizeUrl(String url) {
    if (url.isEmpty) return url;
    if (url.endsWith('/')) return url.substring(0, url.length - 1);
    return url;
  }
}

/// 🌐 API Endpoints Configuration
/// Central configuration for all backend API endpoints
class Endpoints {
  Endpoints._();

  // ==================== BASE URL ====================

  static String get baseUrl => EnvironmentConfig.instance.baseUrl;

  /// Android emulator uses 10.0.2.2 to reach the host machine.
  /// Base URL for development and staging is selected by env values.

  /// Base URL for production is selected in release mode or via
  /// --dart-define=PRODUCTION_API_BASE_URL.

  // ==================== WEBSOCKET ENDPOINTS ====================

  /// Get WebSocket URL for STOMP connections
  /// Converts HTTP/HTTPS base URL to WS/WSS with correct endpoint
  static String getWebSocketUrl() {
    String wsUrl = baseUrl;

    // Remove /api suffix if present
    wsUrl = wsUrl.replaceAll(RegExp(r'/api$'), '');

    // Convert protocol to WebSocket protocol
    if (wsUrl.startsWith('https://')) {
      wsUrl = wsUrl.replaceFirst('https://', 'wss://');
    } else if (wsUrl.startsWith('http://')) {
      wsUrl = wsUrl.replaceFirst('http://', 'ws://');
    }

    // Add /ws endpoint
    wsUrl = '$wsUrl/ws';

    return wsUrl;
  }

  // ==================== AUTH ENDPOINTS ====================

  /// POST - Login endpoint
  static const String login = '/auth/login';

  /// POST - Register endpoint
  static const String register = '/auth/register';

  /// POST - Logout endpoint
  static const String logout = '/auth/logout';

  /// POST - Refresh token endpoint
  static const String refreshToken = '/auth/refresh';

  /// POST - Request password reset endpoint
  static const String requestPasswordReset = '/auth/request-password-reset';

  /// POST - Reset password endpoint
  static const String resetPassword = '/auth/reset-password';

  /// GET - Verify email endpoint
  static const String verifyEmail = '/auth/verify-email';

  /// POST - Resend verification email
  static const String resendVerification = '/auth/resend-verification';

  // ==================== PROPERTY ENDPOINTS ====================

  /// GET - Get all properties (with pagination)
  static const String properties = '/properties';

  /// GET - Get property by ID
  static String propertyById(String id) => '/properties/$id';

  /// POST - Create new property
  static const String createProperty = '/properties';

  /// PUT - Update property
  static String updateProperty(String id) => '/properties/$id';

  /// DELETE - Delete property
  static String deleteProperty(String id) => '/properties/$id';

  /// GET - Search properties
  static const String searchProperties = '/properties/search';

  /// GET - Filter properties
  static const String filterProperties = '/properties/filter';

  /// GET - Get properties by seller
  static String propertiesBySeller(String sellerId) =>
      '/properties/seller/$sellerId';

  /// GET - Get featured/boosted properties
  static const String featuredProperties = '/properties/featured';

  /// GET - Get current seller's listings
  static const String sellerListings = '/properties/my-listed';

  // ==================== MEDIA ENDPOINTS ====================

  /// POST - Upload property media
  static String uploadPropertyMedia(String propertyId) =>
      '/properties/$propertyId/media';

  /// DELETE - Delete property media
  static String deletePropertyMedia(String propertyId, String mediaId) =>
      '/properties/$propertyId/media/$mediaId';

  /// GET - Get property media
  static String getPropertyMedia(String propertyId) =>
      '/properties/$propertyId/media';

  /// GET - Get media by property ID (media service endpoint)
  static String getMediaByPropertyId(String propertyId) => '/media/$propertyId';

  /// POST - Create media entry
  static const String createMedia = '/media';

  /// DELETE - Delete media by ID
  static String deleteMediaById(String id) => '/media/$id';

  /// POST - Upload video file
  static const String uploadVideo = '/media/upload';

  // ==================== USER ENDPOINTS ====================

  /// GET - Get current user profile

  /// GET - Get user by ID
  static String userById(String id) => '/users/$id';

  /// PUT - Update user profile

  /// GET - Get current user profile (alternative endpoint)
  static const String getProfileMe = '/profile/me';

  /// PUT - Update current user profile (alternative endpoint)
  static const String updateProfileMe = '/profile/me';

  /// PUT - Change password
  static const String changePassword = '/users/change-password';

  /// POST - Upload profile picture
  static const String uploadProfilePicture = '/profile/picture';

  /// DELETE - Delete account
  static String deleteAccount(String id) => '/users/$id';

  static const String createReport = '/users/reports';
  static String updateFcmToken(String id) => '/users/$id/fcm-token';

  // ==================== PROPERTY VIEW ENDPOINTS ====================

  /// POST - Track a property view
  static String trackPropertyView(String propertyId) =>
      '/properties/$propertyId/view';

  /// GET - Get property view stats
  static String propertyViewStats(String propertyId) =>
      '/properties/$propertyId/views/stats';

  /// GET - Get views by property
  static String propertyViewsByProperty(String propertyId) =>
      '/property-views/property/$propertyId';

  /// GET - Get views by user
  static String propertyViewsByUser(String userId) =>
      '/property-views/user/$userId';

  // ==================== CHAT ENDPOINTS ====================

  /// GET - Get chat messages for a conversation
  static const String chatMessages = '/chat/messages';

  /// GET - Get chat messages for a specific conversation (paginated)
  static String chatMessagesFor(String conversationId) => '/chat/conversations/$conversationId/messages';

  /// GET - Get all chat conversations
  static const String chatConversations = '/chat/conversations';

  /// POST - Create chat conversation for a property
  static String createChatConversation(String propertyId) =>
      '/chat/conversations/$propertyId';

  /// PUT - Edit chat message
  static String editChatMessage(String messageId) => '/chat/message/$messageId';

  /// DELETE - Delete chat message
  static String deleteChatMessage(String messageId) =>
      '/chat/message/$messageId';

  /// DELETE - Delete conversation
  static String deleteConversation(String conversationId) =>
      '/chat/conversations/$conversationId';

  // ==================== BOOST ENDPOINTS ====================

  /// POST - Purchase/Create boost for property
  static const String purchaseBoost = '/boost';

  /// GET - Get boost by ID
  static String getBoostById(String boostId) => '/boost/$boostId';

  /// GET - Get boost history
  static const String boostHistory = '/boost/status';

  /// GET - Get active boosts for current seller
  static const String activeBoosts = '/boost/my-boosts';

  /// GET - Get boost packages
  static const String boostPackages = '/boost/packages';

  /// GET - Check if property is currently boosted
  static String isPropertyBoosted(String propertyId) =>
      '/boost/property/$propertyId/is-boosted';

  /// GET - Get active boost for property
  static String getActiveBoostForProperty(String propertyId) =>
      '/boost/property/$propertyId/active';

  // ==================== VISIT REQUEST ENDPOINTS ====================

  /// POST - Request property visit
  static const String requestVisit = '/visits';

  /// GET - Get visit requests (for sellers managing their properties)
  static const String visitRequests = '/visits/requests';

  /// GET - Get my visit requests (for clients who requested visits)
  static const String myVisitRequests = '/visits/my-requests';

  /// PUT - Update visit request status
  static String updateVisitStatus(String visitId) => '/visits/$visitId/status';

  /// DELETE - Delete visit request
  static String deleteVisitRequest(String visitId) => '/visits/$visitId';

  // ==================== SELLER ANALYTICS ENDPOINTS ====================

  /// GET - Get seller analytics dashboard
  static const String sellerAnalytics = '/seller/analytics';

  /// GET - Get views over time (last 30 days)
  static const String sellerAnalyticsViewsOverTime =
      '/seller/analytics/views-over-time';

  /// GET - Get messages over time (last 30 days)
  static const String sellerAnalyticsMessagesOverTime =
      '/seller/analytics/messages-over-time';

  /// GET - Get visits over time (last 30 days)
  static const String sellerAnalyticsVisitsOverTime =
      '/seller/analytics/visits-over-time';

  /// GET - Get top performing properties
  static const String sellerAnalyticsTopProperties =
      '/seller/analytics/top-properties';

  // ==================== FEEDBACK ENDPOINTS ====================

  /// POST - Submit feedback
  static const String submitFeedback = '/feedbacks';

  /// GET - Get all feedback (admin)
  static const String allFeedback = '/feedbacks';

  /// GET - Get my feedback
  static String myFeedback(String userId) => '/feedbacks/user/$userId';

  // ==================== NOTIFICATION ENDPOINTS ====================

  /// GET - Get all notifications
  static const String notifications = '/notifications';

  /// PUT - Mark notification as read
  static String markNotificationAsRead(String id) => '/notifications/$id/read';

  /// PUT - Mark all notifications as read
  static const String markAllNotificationsAsRead = '/notifications/read-all';

  /// DELETE - Delete notification
  static String deleteNotification(String id) => '/notifications/$id';

  // ==================== ADMIN ENDPOINTS ====================

  /// GET - Admin dashboard stats
  static const String adminDashboard = '/admin/dashboard';

  /// GET - Get all users (admin)
  static const String adminUsers = '/admin/users';

  /// PUT - Update user status (admin)
  static String adminUpdateUserStatus(String userId) =>
      '/admin/users/$userId/status';

  /// GET - Get all reports (admin)
  static const String adminReports = '/admin/reports';

  /// GET - Get audit logs (admin)
  static const String adminAuditLogs = '/admin/audit-logs';

  /// GET - Platform statistics (admin)
  static const String adminStatistics = '/admin/statistics';

  // ==================== FAVORITES ENDPOINTS ====================

  /// GET - Get user favorites
  static const String favorites = '/favorites';

  /// POST - Add to favorites
  static String addFavorite(String propertyId) => '/favorites/$propertyId';

  /// DELETE - Remove from favorites
  static String removeFavorite(String propertyId) => '/favorites/$propertyId';


  /// Get full URL for an endpoint
  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }

  /// Get base URL based on environment
  static String getBaseUrl() => baseUrl;
}
