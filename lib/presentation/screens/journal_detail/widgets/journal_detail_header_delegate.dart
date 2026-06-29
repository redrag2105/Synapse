import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/presentation/screens/journal_detail/widgets/journal_detail_stats_card.dart';

class JournalDetailHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final String displayName;
  final String? publisher;
  final String? issnL;
  final int worksCount;
  final int citedByCount;
  final int hIndex;
  final bool isOa;
  final bool isInDoaj;

  static const double backRowHeight = 48;
  static const double collapsedBarHeight = 56;

  /// Hero body below the back row: content + orange line + gap above stats.
  static const double expandedBodyHeight = 248;

  /// Half of the stats card sits on the gradient.
  static double get statsOverlap => JournalDetailStatsCard.layoutHeight / 2;

  JournalDetailHeaderDelegate({
    required this.topPadding,
    required this.displayName,
    this.publisher,
    this.issnL,
    required this.worksCount,
    required this.citedByCount,
    required this.hIndex,
    required this.isOa,
    required this.isInDoaj,
  });

  double get heroHeight => topPadding + backRowHeight + expandedBodyHeight;

  @override
  double get maxExtent =>
      heroHeight - statsOverlap + JournalDetailStatsCard.totalHeight;

  @override
  double get minExtent => topPadding + collapsedBarHeight;

  @override
  bool shouldRebuild(covariant JournalDetailHeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding ||
        oldDelegate.displayName != displayName ||
        oldDelegate.publisher != publisher ||
        oldDelegate.issnL != issnL ||
        oldDelegate.worksCount != worksCount ||
        oldDelegate.citedByCount != citedByCount ||
        oldDelegate.hIndex != hIndex ||
        oldDelegate.isOa != isOa ||
        oldDelegate.isInDoaj != isInDoaj;
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
        : 1.0;

    final fadeOpacity = (1.0 - (progress * 2.5)).clamp(0.0, 1.0);
    final collapsedOpacity = (1.0 - fadeOpacity).clamp(0.0, 1.0);

    final paintedGradientHeight =
        (heroHeight - shrinkOffset).clamp(minExtent, heroHeight);
    final statsTop = heroHeight - statsOverlap;
    final expandedTop = topPadding + backRowHeight;
    final expandedClipHeight =
        (paintedGradientHeight - expandedTop).clamp(0.0, double.infinity);

    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: paintedGradientHeight,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.brandBlue900, AppColors.brandBlue700],
                ),
              ),
            ),
          ),
          Positioned(
            top: -30,
            right: -20,
            child: Opacity(
              opacity: fadeOpacity,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
          ),
          Positioned(
            top: paintedGradientHeight - 100,
            left: -30,
            child: Opacity(
              opacity: fadeOpacity,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding,
            left: 0,
            child: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          Positioned(
            top: topPadding + 10,
            left: 56,
            right: 16,
            child: Opacity(
              opacity: collapsedOpacity,
              child: IgnorePointer(
                ignoring: collapsedOpacity < 0.5,
                child: Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h2.copyWith(
                    fontFamily: 'Merriweather',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: expandedTop,
            left: 24,
            right: 24,
            height: expandedClipHeight,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topLeft,
                maxHeight: double.infinity,
                child: Opacity(
                  opacity: fadeOpacity,
                  child: IgnorePointer(
                    ignoring: fadeOpacity < 0.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.book_fill,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SCHOLARLY SOURCE',
                                style: AppTextStyles.metadata.copyWith(
                                  color: Colors.white54,
                                  fontFamily: 'Courier',
                                  fontSize: 10,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (issnL != null && issnL!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'ISSN $issnL',
                                  style: AppTextStyles.metadata.copyWith(
                                    color: Colors.white60,
                                    fontFamily: 'Courier',
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isOa || isInDoaj)
                          Wrap(
                            spacing: 6,
                            children: [
                              if (isOa) _chip('OA', AppColors.success),
                              if (isInDoaj) _chip('DOAJ', AppColors.warning),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h1.copyWith(
                        fontFamily: 'Merriweather',
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (publisher != null && publisher!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.building_2_fill,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              publisher!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.metadata.copyWith(
                                color: Colors.white.withValues(alpha: 0.78),
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    Container(
                      width: 40,
                      height: 3,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: statsTop,
            left: 0,
            right: 0,
            child: JournalDetailStatsCard(
              worksCount: worksCount,
              citedByCount: citedByCount,
              hIndex: hIndex,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: AppTextStyles.metadata.copyWith(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
