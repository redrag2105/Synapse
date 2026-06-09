import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synapse/app/config/app_colors.dart';

class PublicationCardSkeleton extends StatelessWidget {
  const PublicationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.borderGray, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 150, height: 14, color: Colors.white),
            const SizedBox(height: 12),
            Container(width: double.infinity, height: 22, color: Colors.white),
            const SizedBox(height: 6),
            Container(width: 200, height: 22, color: Colors.white),
            const SizedBox(height: 16),
            Container(width: 180, height: 14, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 250, height: 14, color: Colors.white),
            const SizedBox(height: 16),
            Container(width: 100, height: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
