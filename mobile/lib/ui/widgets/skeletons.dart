import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:homely/core/theme/app_colors.dart';

class SimpleListSkeleton extends StatelessWidget {
  final int items;
  const SimpleListSkeleton({this.items = 5, super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.subtleBackground,
      highlightColor: AppColors.background,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: items,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 120, color: Colors.white),
                const SizedBox(height: 10),
                Container(height: 12, width: double.infinity, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 12, width: 200, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
