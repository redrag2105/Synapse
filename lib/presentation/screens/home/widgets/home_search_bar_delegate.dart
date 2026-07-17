import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/domain/entities/topic_entity.dart';
import 'package:synapse/presentation/widgets/universal_search_bar.dart';

/// Pinned search strip that sits below the branded Home header.
class HomeSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final String initialValue;
  final String hintText;
  final Key? searchFieldKey;
  final ValueChanged<bool> onFocusChanged;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<TopicEntity> onTopicSelected;

  HomeSearchBarDelegate({
    required this.initialValue,
    required this.onFocusChanged,
    required this.onSubmitted,
    required this.onTopicSelected,
    this.hintText = 'Search for topics...',
    this.searchFieldKey,
  });

  static const double barHeight = 72;

  @override
  double get maxExtent => barHeight;

  @override
  double get minExtent => barHeight;

  @override
  bool shouldRebuild(covariant HomeSearchBarDelegate oldDelegate) {
    return oldDelegate.initialValue != initialValue ||
        oldDelegate.hintText != hintText;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceGray,
        border: Border(
          bottom: BorderSide(color: AppColors.borderGray, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: UniversalSearchBar(
          key: ValueKey(initialValue),
          searchFieldKey: searchFieldKey,
          initialValue: initialValue,
          hintText: hintText,
          enableAutocomplete: true,
          // Empty Enter clears results; blur with empty text restores query.
          restoreOnEmptySubmit: false,
          optionsTopGap: 16,
          onFocusChanged: onFocusChanged,
          onSubmitted: onSubmitted,
          onTopicSelected: onTopicSelected,
        ),
      ),
    );
  }
}
