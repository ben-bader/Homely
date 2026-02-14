import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../auth/screens/login_screen.dart';
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
      title: 'Discover Properties',
      subtitle: 'Homes, villas & studios near you',
      image: 'assets/onboarding1.jpg',
    ),
    OnboardingItem(
      title: 'Chat With Sellers',
      subtitle: 'Secure and instant conversations',
      image: 'assets/onboarding2.jpg',
    ),
    OnboardingItem(
      title: 'Sell Smarter',
      subtitle: 'Boost your listings and reach more buyers',
      image: 'assets/onboarding3.jpg',
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
        MaterialPageRoute(builder: (_) => LoginScreen()),
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
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = index == items.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 🔁 SWIPEABLE BACKGROUND PAGES
          PageView.builder(
            controller: _controller,
            itemCount: items.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) => setState(() => index = i),
            itemBuilder: (_, i) => Image.asset(
              items[i].image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          /// 🌈 GRADIENT OVERLAY
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.25),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0, 0.3, 0.55, 1],
                  ),
                ),
              ),
            ),
          ),

          /// ⏭️ SKIP BUTTON
          SafeArea(
            child: Positioned(
              top: 16,
              right: 20,
              child: TextButton(
                onPressed: skip,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),

          /// 🏷️ TITLE IN UPPER SECTION (encore plus en haut)
          Positioned(
            left: 28,
            right: 28,
            top:
                MediaQuery.of(context).size.height *
                0.15, // 15% du haut (encore plus haut)
            child: Text(
              items[index].title,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 52, // Plus grand
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -1.5,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(0, 2),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),

          /// 📄 BOTTOM CONTENT (SUBTITLE, INDICATORS & BUTTON)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: false,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// 📝 SUBTITLE
                      IgnorePointer(
                        child: Text(
                          items[index].subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.5,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// 🔘 INDICATORS
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

                      /// ▶️ NEXT BUTTON WITH HOVER EFFECT
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) => setState(() => isHovering = true),
                        onExit: (_) => setState(() => isHovering = false),
                        child: Container(
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
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
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 1,
                                offset: const Offset(0, -1),
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
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  style: TextStyle(
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
