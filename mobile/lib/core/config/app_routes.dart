import 'package:flutter/material.dart';


class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String verifyEmail = '/verify-email';

  static const String home = '/home';
  static const String main = '/main';

  // Property Routes
  static const String propertyList = '/properties';
  static const String propertyDetail = '/property/:id';
  static const String propertyCreate = '/property/create';
  static const String propertyEdit = '/property/:id/edit';
  static const String propertySearch = '/property/search';
  static const String propertyFilter = '/property/filter';

  // User Routes
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  // Chat Routes
  static const String chatList = '/chat';
  static const String chatConversation = '/chat/:id';

  // Boost Routes
  static const String boostPurchase = '/boost/purchase';
  static const String boostHistory = '/boost/history';

  // Visit Routes
  static const String visitRequest = '/visit/request';
  static const String visitHistory = '/visit/history';

  // Feedback Routes
  static const String feedbackCreate = '/feedback/create';
  static const String feedbackList = '/feedback';

  // Admin Routes (if accessed from mobile)
  static const String adminDashboard = '/admin/dashboard';
  static const String adminReports = '/admin/reports';
  static const String adminUsers = '/admin/users';

  // Other Routes
  static const String favorites = '/favorites';
  static const String about = '/about';
  static const String termsAndConditions = '/terms';
  static const String privacyPolicy = '/privacy';
  static const String help = '/help';

  // ==================== ROUTE GENERATOR ====================

  /// Main route generator function
  /// Handles navigation and passes arguments between screens
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract route name and arguments
    final String? routeName = settings.name;
    final Object? arguments = settings.arguments;

    // Route selection
    switch (routeName) {
      // Auth Routes
      case splash:
        return _buildRoute(
          const Placeholder(), // Replace with SplashScreen()
          settings: settings,
        );

      case login:
        return _buildRoute(
          const Placeholder(), // Replace with LoginScreen()
          settings: settings,
        );

      case signup:
        return _buildRoute(
          const Placeholder(), // Replace with SignupScreen()
          settings: settings,
        );

      case forgotPassword:
        return _buildRoute(
          const Placeholder(), // Replace with ForgotPasswordScreen()
          settings: settings,
        );

      // Main Routes
      case home:
      case main:
        return _buildRoute(
          const Placeholder(), // Replace with MainScreen() or HomeScreen()
          settings: settings,
        );

      // Property Routes
      case propertyList:
        return _buildRoute(
          const Placeholder(), // Replace with PropertyListScreen()
          settings: settings,
        );

      case propertyCreate:
        return _buildRoute(
          const Placeholder(), // Replace with PropertyCreateScreen()
          settings: settings,
        );

      case propertySearch:
        return _buildRoute(
          const Placeholder(), // Replace with PropertySearchScreen()
          settings: settings,
        );

      // Profile Routes
      case profile:
        return _buildRoute(
          const Placeholder(), // Replace with ProfileScreen()
          settings: settings,
        );
      // Chat Routes
      case chatList:
        return _buildRoute(
          const Placeholder(), // Replace with ChatListScreen()
          settings: settings,
        );

      // Default: 404 Not Found
      default:
        return _buildRoute(
          _NotFoundScreen(routeName: routeName ?? 'Unknown'),
          settings: settings,
        );
    }
  }

  // ==================== HELPER METHODS ====================

  /// Build a MaterialPageRoute with optional custom transition
  static MaterialPageRoute _buildRoute(
    Widget screen, {
    required RouteSettings settings,
    bool fullscreenDialog = false,
  }) {
    return MaterialPageRoute(
      builder: (_) => screen,
      settings: settings,
      fullscreenDialog: fullscreenDialog,
    );
  }

  /// Navigate to a named route
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Replace current route with a named route
  static Future<T?> replaceTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, void>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Clear stack and navigate to a named route
  static Future<T?> clearAndNavigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Go back
  static void goBack(BuildContext context, {Object? result}) {
    Navigator.pop(context, result);
  }

  /// Check if can go back
  static bool canGoBack(BuildContext context) {
    return Navigator.canPop(context);
  }
}

// ==================== NOT FOUND SCREEN ====================

/// 404 Not Found Screen
class _NotFoundScreen extends StatelessWidget {
  final String routeName;

  const _NotFoundScreen({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              '404',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Route "$routeName" not found',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
