import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_links/app_links.dart';
import 'core/theme/app_colors.dart';
import 'data/datasources/local/secure_storage.dart';
import 'infrastructure/services/notification_service.dart';
import 'infrastructure/services/chat_service.dart';
import 'ui/providers/auth_providers.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/email_verification_screen.dart';
import 'ui/screens/auth/forgot_password_screen.dart';
import 'ui/screens/auth/reset_password_screen.dart';
import 'ui/screens/onboarding/onboarding_screen.dart';
import 'ui/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await NotificationService().init();
  await ChatService().init();

  final appLinks = AppLinks();
  String? initialLink;
  try {
    initialLink = (await appLinks.getInitialLink())?.toString();
  } catch (_) {}

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
        '/login': (_) => const LoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/email-verification': (_) => const EmailVerificationScreen(),
        '/reset-password': (_) => const ResetPasswordScreen(),
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) _handleDeepLink(uri.toString());
    });
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (widget.initialLink != null) {
      _handleDeepLink(widget.initialLink!);
      return;
    }
    final isLoggedIn = await ref.read(authRepositoryProvider).isLoggedIn();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            isLoggedIn ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
    final storage = ref.read(secureStorageProvider);
    NotificationService().startPolling(storage);
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
