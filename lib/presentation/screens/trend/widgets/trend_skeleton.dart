import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TrendSkeleton extends StatelessWidget {
  const TrendSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        bottom: bottomPadding + 40,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildSkeletonBox(height: 105)),
                const SizedBox(width: 12),
                Expanded(child: _buildSkeletonBox(height: 105)),
              ],
            ),
            const SizedBox(height: 16),

            _buildSkeletonBox(height: 300),
            const SizedBox(height: 16),

            _buildSkeletonBox(height: 110),
            const SizedBox(height: 16),

            _buildSkeletonBox(height: 95),
            const SizedBox(height: 16),

            _buildSkeletonBox(height: 20, width: 180, borderRadius: 6),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _buildSkeletonBox(height: 75)),
                const SizedBox(width: 12),
                Expanded(child: _buildSkeletonBox(height: 75)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonBox({
    required double height,
    double? width,
    double borderRadius = 16,
  }) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
