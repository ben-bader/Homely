import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/auth/screens/reset_password_screen.dart';
import 'package:mobile/features/notifications/services/notification_service.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/email_verification_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/property/screens/home_screen.dart';
import 'features/auth/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().init();

  // Handle initial deep link
  final appLinks = AppLinks();
  String? initialLink;
  try {
    initialLink = (await appLinks.getInitialLink())?.toString();
  } catch (e) {
    // Handle error
  }

  runApp(
    ProviderScope(
      child: HomelyApp(initialLink: initialLink),
    ),
  );
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
        '/login': (context) => const LoginScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/email-verification': (context) => const EmailVerificationScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
      },
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.grey,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F7F7),
    );

    return base.copyWith(
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final String? initialLink;

  const SplashScreen({super.key, this.initialLink});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;
  StreamSubscription? _linkSubscription;
  final AppLinks _appLinks = AppLinks();

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

    // Listen for incoming deep links
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri.toString());
      }
    });

    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check for initial deep link
    if (widget.initialLink != null) {
      _handleDeepLink(widget.initialLink!);
      return;
    }

    final isLoggedIn = await _authService.isLoggedIn();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            isLoggedIn ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
    NotificationService().startPolling(_authService);
  }

  void _handleDeepLink(String link) {
    final uri = Uri.parse(link);

    if (uri.pathSegments.contains('verify-email')) {
      final token = uri.queryParameters['token'];
      if (token != null) {
        Navigator.pushReplacementNamed(
          context,
          '/email-verification',
          arguments: token,
        );
        return;
      }
    } else if (uri.pathSegments.contains('reset-password')) {
      final token = uri.queryParameters['token'];
      if (token != null) {
        Navigator.pushReplacementNamed(
          context,
          '/reset-password',
          arguments: token,
        );
        return;
      }
    }

    // If no valid deep link, proceed with normal auth check
    _checkAuthStatus();
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
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
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

            /// Title using theme (IMPORTANT)
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
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 48),

            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: Colors.white.withOpacity(0.8),
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