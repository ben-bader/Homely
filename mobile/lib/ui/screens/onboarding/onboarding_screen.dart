import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';
import '../models/onboarding_item.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int index = 0;
  bool isHovering = false;

  final List<OnboardingItem> items = const [
    OnboardingItem(
      title: 'Discover\nProperties',
      description:
          'Browse thousands of homes, villas & studios near you — curated just for your lifestyle and budget.',
      imagePath: 'assets/onboarding1.jpg',
    ),
    OnboardingItem(
      title: 'Chat With\nSellers',
      description:
          'Connect directly with property owners through secure, real-time conversations. No middlemen, no delays.',
      imagePath: 'assets/onboarding2.jpg',
    ),
    OnboardingItem(
      title: 'Sell\nSmarter',
      description:
          'Boost your listings, reach thousands of serious buyers, and close deals faster than ever before.',
      imagePath: 'assets/onboarding3.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void next() {
    if (index == items.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = index == items.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Background image ──────────────────────────────
          PageView.builder(
            controller: _controller,
            itemCount: items.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) => setState(() => index = i),
            itemBuilder: (_, i) => Image.asset(
              items[i].imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // ── Gradient overlay ──────────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.30),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.90),
                    ],
                    stops: const [0, 0.3, 0.50, 1],
                  ),
                ),
              ),
            ),
          ),

          // ── Top bar ───────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 120,
                    fit: BoxFit.contain,
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                  TextButton(
                    onPressed: skip,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.18),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.35),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Slide title ───────────────────────────────────
          Positioned(
            left: 28,
            right: 28,
            top: MediaQuery.of(context).size.height * 0.16,
            child: Text(
              items[index].title.toUpperCase(),
              textAlign: TextAlign.left,
              style: GoogleFonts.outfit(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.05,
                letterSpacing: 1,
                shadows: const [
                  Shadow(
                    color: Color(0x13000000),
                    offset: Offset(0, 2),
                    blurRadius: 16,
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom content ────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IgnorePointer(
                      child: Text(
                        items[index].description,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 1.6,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Dots ─────────────────────────────────
                    IgnorePointer(
                      child: Row(
                        children: List.generate(
                          items.length,
                          (dot) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: index == dot ? 32 : 8,
                            decoration: BoxDecoration(
                              color: index == dot
                                  ? Colors.white
                                  : Colors.white38,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── CTA Button ───────────────────────────
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => setState(() => isHovering = true),
                      onExit: (_) => setState(() => isHovering = false),
                      child: Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.black,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                style: GoogleFonts.outfit(
                                  fontSize: isHovering ? 19 : 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: isHovering ? 0.8 : 0.5,
                                  color: Colors.black,
                                ),
                                child: Text(isLast ? 'Get Started' : 'Next'),
                              ),
                              const SizedBox(width: 8),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                transform: Matrix4.identity()
                                  ..scale(isHovering ? 1.2 : 1.0),
                                child: Icon(
                                  isLast
                                      ? Icons.arrow_forward_rounded
                                      : Icons.arrow_forward_ios_rounded,
                                  size: isLast ? 22 : 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
