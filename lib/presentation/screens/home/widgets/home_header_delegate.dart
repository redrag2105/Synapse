import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';

class HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;

  HomeHeaderDelegate({required this.topPadding});

  @override
  double get maxExtent => topPadding + 220.0;

  @override
  double get minExtent => topPadding + 60.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double extentDiff = maxExtent - minExtent;
    final double progress = (shrinkOffset / extentDiff).clamp(0.0, 1.0);

    final double fadeOpacity = (1.0 - (progress * 2.5)).clamp(0.0, 1.0);

    final double maxTitleSize = 40.0;
    final double minTitleSize = 20.0;
    final double currentTitleSize =
        maxTitleSize - ((maxTitleSize - minTitleSize) * progress);

    final double expandedTitleY = topPadding + 70.0;
    final double collapsedTitleY = topPadding + 16.0;
    final double currentTitleY =
        expandedTitleY - ((expandedTitleY - collapsedTitleY) * progress);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandBlue900, AppColors.brandBlue700],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: topPadding + 16,
            left: 24,
            right: 24,
            child: Opacity(
              opacity: fadeOpacity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ISSN 2961-0504',
                    style: AppTextStyles.metadata.copyWith(
                      color: Colors.white54,
                      fontFamily: 'Courier',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white54),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'OPEN ACCESS',
                      style: AppTextStyles.metadata.copyWith(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: currentTitleY,
            left: 24,
            child: Text(
              'SYNAPSE',
              style: AppTextStyles.h1.copyWith(
                color: Colors.white,
                fontSize: currentTitleSize,
                letterSpacing: 4.0 - (progress * 2),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Positioned(
            top: expandedTitleY + maxTitleSize + 8,
            left: 24,
            child: Opacity(
              opacity: fadeOpacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Journal Trend Analyzer\n& Bibliometrics',
                    style: AppTextStyles.h2.copyWith(
                      fontFamily: 'Merriweather',
                      fontStyle: FontStyle.italic,
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(width: 40, height: 3, color: AppColors.warning),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
