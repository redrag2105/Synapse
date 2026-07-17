import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';

/// Collapsible branded header for the Keywords tab.
class KeywordsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;

  KeywordsHeaderDelegate({required this.topPadding});

  @override
  double get maxExtent => topPadding + 176.0;

  @override
  double get minExtent => topPadding + 60.0;

  @override
  bool shouldRebuild(covariant KeywordsHeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final extentDiff = maxExtent - minExtent;
    final progress = (shrinkOffset / extentDiff).clamp(0.0, 1.0);
    final fadeOpacity = (1.0 - (progress * 2.2)).clamp(0.0, 1.0);

    final maxTitleSize = 32.0;
    final minTitleSize = 20.0;
    final currentTitleSize =
        maxTitleSize - ((maxTitleSize - minTitleSize) * progress);

    final expandedTitleY = topPadding + 40.0;
    final collapsedTitleY = topPadding + 16.0;
    final currentTitleY =
        expandedTitleY - ((expandedTitleY - collapsedTitleY) * progress);

    // Keep subtitle well clear of the title baseline.
    final subtitleTop = expandedTitleY + maxTitleSize + 16;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandBlue900, AppColors.brandBlue600],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: currentTitleY,
            left: 24,
            right: 24,
            child: Text(
              'Keywords',
              style: AppTextStyles.h1.copyWith(
                color: Colors.white,
                fontSize: currentTitleSize,
                letterSpacing: 1.2 - (progress * 0.6),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            top: subtitleTop,
            left: 24,
            right: 24,
            child: Opacity(
              opacity: fadeOpacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore research themes across\nscholarly literature',
                    style: AppTextStyles.h2.copyWith(
                      fontFamily: 'Merriweather',
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 36,
                    height: 3,
                    color: AppColors.brandGold,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
