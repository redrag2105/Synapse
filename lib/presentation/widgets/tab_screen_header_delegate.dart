import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';

class TabScreenHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final String title;
  final String subtitle;

  TabScreenHeaderDelegate({
    required this.topPadding,
    required this.title,
    this.subtitle = '',
  });

  @override
  double get maxExtent => topPadding + (subtitle.isEmpty ? 72 : 96);

  @override
  double get minExtent => topPadding + 56;

  @override
  bool shouldRebuild(covariant TabScreenHeaderDelegate oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.subtitle != subtitle ||
        oldDelegate.topPadding != topPadding;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final extentDiff = maxExtent - minExtent;
    final progress = extentDiff > 0
        ? (shrinkOffset / extentDiff).clamp(0.0, 1.0)
        : 0.0;
    final fadeOpacity = (1.0 - (progress * 2)).clamp(0.0, 1.0);

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
            top: topPadding + 12,
            left: 20,
            right: 20,
            child: Text(
              title,
              style: AppTextStyles.h2.copyWith(
                color: Colors.white,
                fontSize: 20 - (4 * progress),
              ),
            ),
          ),
          if (subtitle.isNotEmpty)
            Positioned(
              top: topPadding + 44,
              left: 20,
              right: 20,
              child: Opacity(
                opacity: fadeOpacity,
                child: Text(
                  subtitle,
                  style: AppTextStyles.metadata.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Merriweather',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
