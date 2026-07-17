import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';

/// Pinned gradient header: back + "Keyword Detail", keyword subtitle below.
class KeywordDetailHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final String keyword;

  KeywordDetailHeaderDelegate({
    required this.topPadding,
    required this.keyword,
  });

  static const double _contentHeight = 96;

  @override
  double get maxExtent => topPadding + _contentHeight;

  @override
  double get minExtent => topPadding + _contentHeight;

  @override
  bool shouldRebuild(covariant KeywordDetailHeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding ||
        oldDelegate.keyword != keyword;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandBlue900, AppColors.brandBlue700],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.back,
                      color: Colors.white,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Keyword Detail',
                      style: AppTextStyles.h2.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                keyword,
                style: AppTextStyles.metadata.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontFamily: 'Merriweather',
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
