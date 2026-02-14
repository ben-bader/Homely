import 'package:flutter/material.dart';

class OnboardingController {
  final PageController pageController = PageController();
  int currentIndex = 0;

  void onPageChanged(int index) {
    currentIndex = index;
  }
}
