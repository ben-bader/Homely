import 'package:flutter/foundation.dart';

/// 🌐 API Endpoints Configuration
/// Central configuration for all backend API endpoints
class Endpoints {
  Endpoints._();

  // ==================== BASE URL ====================

  /// Android emulator uses 10.0.2.2 to reach the host machine.
  static const String androidDevBaseUrl = 'http://10.0.2.2:8082/api';

  /// Base URL for development
  static const String devBaseUrl = 'http://localhost:8082/api';

  /// Base URL for production
  static const String prodBaseUrl = 'https://api.homely.com/api';

  /// Base URL for the backend API
  static String get baseUrl => kReleaseMode ? prodBaseUrl : _debugBaseUrl();

  static String _debugBaseUrl() {
    if (kIsWeb) return devBaseUrl;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidDevBaseUrl;
      default:
        return devBaseUrl;
    }
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
  static String getMediaByPropertyId(String propertyId) =>
      '/media/$propertyId';

  /// POST - Create media entry
  static const String createMedia = '/media';

  /// DELETE - Delete media by ID
  static String deleteMediaById(String id) => '/media/$id';

  /// POST - Upload video file
  static const String uploadVideo = '/media/upload';

  // ==================== USER ENDPOINTS ====================

  /// GET - Get current user profile
  static const String profile = '/users/profile';

  /// GET - Get user by ID
  static String userById(String id) => '/users/$id';

  /// PUT - Update user profile
  static const String updateProfile = '/users/profile';

  /// GET - Get current user profile (alternative endpoint)
  static const String getProfileMe = '/profile/me';

  /// PUT - Update current user profile (alternative endpoint)
  static const String updateProfileMe = '/profile/me';

  /// PUT - Change password
  static const String changePassword = '/users/change-password';

  /// POST - Upload profile picture
  static const String uploadProfilePicture = '/users/profile/picture';

  /// DELETE - Delete account
  static const String deleteAccount = '/users/account';

  // ==================== CONVERSATION/CHAT ENDPOINTS ====================

  /// GET - Get all conversations
  static const String conversations = '/conversations';

  /// GET - Get conversation by ID
  static String conversationById(String id) => '/conversations/$id';

  /// POST - Create new conversation
  static const String createConversation = '/conversations';

  /// GET - Get messages in conversation
  static String conversationMessages(String conversationId) =>
      '/conversations/$conversationId/messages';

  /// POST - Send message
  static String sendMessage(String conversationId) =>
      '/conversations/$conversationId/messages';

  /// PUT - Mark conversation as read
  static String markAsRead(String conversationId) =>
      '/conversations/$conversationId/read';

  // ==================== CHAT ENDPOINTS (ALTERNATIVE) ====================

  /// GET - Get chat messages
  static const String chatMessages = '/chat/messages';

  /// GET - Get chat conversations
  static const String chatConversations = '/chat/conversations';

  /// POST - Create chat conversation for property
  static String createChatConversation(String propertyId) =>
      '/chat/conversations/$propertyId';

  /// PUT - Edit chat message
  static String editChatMessage(String messageId) => '/chat/message/$messageId';

  /// DELETE - Delete chat message
  static String deleteChatMessage(String messageId) => '/chat/message/$messageId';

  // ==================== BOOST ENDPOINTS ====================

  /// POST - Purchase boost for property
  static String purchaseBoost(String propertyId) =>
      '/properties/$propertyId/boost';

  /// GET - Get boost history
  static const String boostHistory = '/boost/history';

  /// GET - Get active boosts
  static const String activeBoosts = '/boost/active';

  // ==================== VISIT REQUEST ENDPOINTS ====================

  /// POST - Request property visit
  static String requestVisit(String propertyId) =>
      '/properties/$propertyId/visits';

  /// GET - Get visit requests (for sellers)
  static const String visitRequests = '/visits/requests';

  /// GET - Get my visit requests (for clients)
  static const String myVisitRequests = '/visits/my-requests';

  /// PUT - Update visit request status
  static String updateVisitStatus(String visitId) => '/visits/$visitId/status';

  // ==================== FEEDBACK ENDPOINTS ====================

  /// POST - Submit feedback
  static const String submitFeedback = '/feedback';

  /// GET - Get all feedback (admin)
  static const String allFeedback = '/feedback/all';

  /// GET - Get my feedback
  static const String myFeedback = '/feedback/my';

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

  // ==================== PROPERTY VIEW TRACKING ====================

  /// POST - Track property view
  static String trackPropertyView(String propertyId) =>
      '/properties/$propertyId/view';

  /// GET - Get property view statistics
  static String propertyViewStats(String propertyId) =>
      '/properties/$propertyId/views/stats';

  // ==================== HELPER METHODS ====================

  /// Get full URL for an endpoint
  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }

  /// Get base URL based on environment
  static String getBaseUrl({bool isProduction = false}) {
    return isProduction ? prodBaseUrl : devBaseUrl;
  }
}
