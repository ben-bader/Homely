import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_links/app_links.dart';
import 'package:homely/data/datasources/local/secure_storage.dart';
import 'package:homely/infrastructure/services/app_initializer.dart';
import 'package:homely/infrastructure/services/notification_service.dart';
import 'package:homely/ui/screens/auth/email_verification_screen.dart';
import 'package:homely/ui/screens/auth/forgot_password_screen.dart';
import 'package:homely/ui/screens/auth/login_screen.dart';
import 'package:homely/ui/screens/auth/reset_password_screen.dart';
import 'package:homely/ui/screens/home/home_screen.dart';
import 'package:homely/ui/screens/onboarding/onboarding_screen.dart';
import 'package:homely/ui/screens/seller/seller_dashboard_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Notification initialization is started later after login so first render is not blocked.
  final appLinks = AppLinks();
  String? initialLink;
  try {
    initialLink = (await appLinks.getInitialLink())?.toString();
  } catch (e) {
    // Handle error
  }

  runApp(ProviderScope(child: HomelyApp(initialLink: initialLink)));
}

class HomelyApp extends StatelessWidget {
  final String? initialLink;
  const HomelyApp({super.key, this.initialLink});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homely',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: SplashScreen(initialLink: initialLink),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/email-verification': (_) => const EmailVerificationScreen(),
        '/reset-password': (_) => const ResetPasswordScreen(),
        SellerDashboardScreen.routeName: (_) => const SellerDashboardScreen(),
      },
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0F172A),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    );
    return base.copyWith(
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme),
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  final String? initialLink;
  const SplashScreen({super.key, this.initialLink});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;
  StreamSubscription? _linkSubscription;
  final AppLinks _appLinks = AppLinks();
  
  /// Flag to ensure navigation happens only once
  bool _hasNavigated = false;

  SecureStorage get _authService => SecureStorage();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Listen for incoming deep links (after app is already running)
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) _handleDeepLinkNavigation(uri.toString());
    });
    
    // Start the single startup flow
    _startupFlow();
  }

  /// Single startup flow that runs exactly once
  Future<void> _startupFlow() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted || _hasNavigated) return;

    // Step 1: Check if there's an initial deep link (handles reset-password and verify-email)
    if (widget.initialLink != null) {
      final handled = _handleInitialDeepLink(widget.initialLink!);
      if (handled) {
        return; // Navigation was handled by deep link
      }
    }

    // Step 2: Normal auth flow (only if deep link didn't handle navigation)
    await _navigateBasedOnAuthStatus();
  }

  /// Handles deep links provided at app startup
  /// Returns true if navigation was performed, false otherwise
  bool _handleInitialDeepLink(String link) {
    if (_hasNavigated) return false;

    final uri = Uri.parse(link);

    if (uri.pathSegments.contains('verify-email')) {
      final token = uri.queryParameters['token'];
      if (token != null) {
        _hasNavigated = true;
        Navigator.pushReplacementNamed(
          context,
          '/email-verification',
          arguments: token,
        );
        return true;
      }
    }

    // No valid deep link action was taken
    return false;
  }

  /// Handles deep links received while app is already running
  /// This is separate from startup deep link handling
  void _handleDeepLinkNavigation(String link) {
    // Only handle if we're on home screen or can navigate to these screens
    final uri = Uri.parse(link);
    
    if (uri.pathSegments.contains('verify-email')) {
      final token = uri.queryParameters['token'];
      if (token != null) {
        Navigator.pushNamed(
          context,
          '/email-verification',
          arguments: token,
        );
      }
    }
  }

  /// Navigate based on authentication status (only called once during startup)
  Future<void> _navigateBasedOnAuthStatus() async {
    if (_hasNavigated) return;

    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (!mounted) return;

      _hasNavigated = true;

      if (isLoggedIn) {
        if (!mounted) return;
        _hasNavigated = true;
        unawaited(AppInitializer().initializeAfterLogin());
        Navigator.pushReplacementNamed(
          context,
          '/home',
        );
      } else {
        Navigator.pushReplacementNamed(
          context,
          '/onboarding',
        );
      }
    } catch (e) {
      print('Error during auth status check: $e');
      if (mounted) {
        _hasNavigated = true;
        Navigator.pushReplacementNamed(
          context,
          '/onboarding',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.home_outlined,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Homely',
              style: tt.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Real Estate Partner',
              style: tt.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: Colors.white.withValues(alpha: 0.8),
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _linkSubscription?.cancel();
    super.dispose();
  }
}
