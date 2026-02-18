import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BottomNavTab {
  home,
  explore,
  favorites,
  chat,
  profile,
}

final bottomNavTabProvider = StateProvider<BottomNavTab>((ref) => BottomNavTab.home);
