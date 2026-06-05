import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/presentation/widgets/search_bar.dart';

class TrendHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final String currentTitle;
  final double focusProgress;
  final ValueChanged<bool> onFocusChanged;
  final Function(String keyword, {String? topicId, String? topicName}) onSearch;

  TrendHeaderDelegate({
    required this.topPadding,
    required this.currentTitle,
    this.focusProgress = 0.0,
    required this.onFocusChanged,
    required this.onSearch,
  });

  @override
  double get maxExtent {
    final double expandedHeight = topPadding + 160.0;
    final double collapsedHeight = topPadding + 65.0;
    return expandedHeight -
        ((expandedHeight - collapsedHeight) * focusProgress);
  }

  @override
  double get minExtent => topPadding + 65.0;

  @override
  bool shouldRebuild(covariant TrendHeaderDelegate oldDelegate) {
    return oldDelegate.currentTitle != currentTitle ||
        oldDelegate.topPadding != topPadding ||
        oldDelegate.focusProgress != focusProgress;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double expandedHeight = topPadding + 160.0;
    final double currentMaxExtent = maxExtent;
    final double extentDiff = currentMaxExtent - minExtent;

    final double scrollProgress = extentDiff > 0
        ? (shrinkOffset / extentDiff).clamp(0.0, 1.0)
        : 1.0;

    final double collapseProgress = (scrollProgress + focusProgress).clamp(
      0.0,
      1.0,
    );
    final double titleOpacity = (1.0 - focusProgress).clamp(0.0, 1.0);

    final double searchBarOpacity =
        ((1.0 - (scrollProgress * 2.1)).clamp(0.0, 1.0) + focusProgress).clamp(
          0.0,
          1.0,
        );

    final double expandedTitleY = topPadding + 16.0;
    final double collapsedTitleY = topPadding + 8.0;
    final double currentTitleY =
        expandedTitleY -
        ((expandedTitleY - collapsedTitleY) * collapseProgress);

    final double expandedSubY = topPadding + 46.0;
    final double collapsedSubY = topPadding + 32.0;
    final double currentSubY =
        expandedSubY - ((expandedSubY - collapsedSubY) * collapseProgress);

    final double titleScale = 1.0 - (0.27 * collapseProgress);
    final double subScale = 1.0 - (0.14 * collapseProgress);

    final double unfocusedTop = (expandedHeight - shrinkOffset) - 64.0;
    final double focusedTop = topPadding + 8.0;
    final double searchBarTop =
        unfocusedTop + ((focusedTop - unfocusedTop) * focusProgress);

    final double searchBarLeft = 16.0 + (40.0 * focusProgress);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandBlue900, AppColors.brandBlue700],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: topPadding + 8.0,
            left: 8,
            child: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),

          Positioned(
            top: currentTitleY,
            left: 56,
            child: Opacity(
              opacity: titleOpacity,
              child: Transform.scale(
                scale: titleScale,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Trend Analysis',
                  style: AppTextStyles.h2.copyWith(
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: currentSubY,
            left: 56,
            right: 16,
            child: Opacity(
              opacity: titleOpacity,
              child: Transform.scale(
                scale: subScale,
                alignment: Alignment.centerLeft,
                child: Text(
                  currentTitle,
                  style: AppTextStyles.metadata.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Merriweather',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),

          Positioned(
            top: searchBarTop,
            left: searchBarLeft,
            right: 16,
            child: IgnorePointer(
              ignoring: searchBarOpacity < 0.5,
              child: Opacity(
                opacity: searchBarOpacity,
                child: UniversalSearchBar(
                  hintText: 'Search topic to analyze trend...',
                  enableAutocomplete: true,
                  onFocusChanged: onFocusChanged,
                  onSubmitted: (keyword) => onSearch(keyword),
                  onTopicSelected: (topic) => onSearch(
                    topic.displayName,
                    topicId: topic.id,
                    topicName: topic.displayName,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
