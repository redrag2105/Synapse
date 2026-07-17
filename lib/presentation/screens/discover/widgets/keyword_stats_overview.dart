import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/config/test_keys.dart';
import 'package:synapse/domain/entities/keyword_entity.dart';

class KeywordStatsOverview extends StatelessWidget {
  final KeywordEntity? topKeyword;
  final int topKeywordSearchCount;
  final int trendingCount;
  final int frequentCount;
  final bool isLoading;
  final String emptyTopLabel;
  final VoidCallback? onTopKeywordTap;

  const KeywordStatsOverview({
    super.key,
    this.topKeyword,
    this.topKeywordSearchCount = 0,
    this.trendingCount = 0,
    this.frequentCount = 0,
    this.isLoading = false,
    this.emptyTopLabel = 'Search topics on Home to personalize',
    this.onTopKeywordTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _KeywordStatsSkeleton();
    }

    return Material(
      key: TestKeys.keywordsStatistics,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TopKeywordHighlight(
            keyword: topKeyword,
            searchCount: topKeywordSearchCount,
            emptyLabel: emptyTopLabel,
            onTap: onTopKeywordTap,
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _CompactStatTile(
                    icon: CupertinoIcons.flame,
                    value: trendingCount > 0 ? '$trendingCount' : '—',
                    label: 'Trending now',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CompactStatTile(
                    icon: CupertinoIcons.chart_bar,
                    value: frequentCount > 0 ? '$frequentCount' : '—',
                    label: 'Most frequent',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopKeywordHighlight extends StatelessWidget {
  final KeywordEntity? keyword;
  final int searchCount;
  final String emptyLabel;
  final VoidCallback? onTap;

  const _TopKeywordHighlight({
    this.keyword,
    required this.searchCount,
    required this.emptyLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasKeyword = keyword != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasKeyword ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.brandBlue900,
                AppColors.brandBlue700.withValues(alpha: 0.92),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandBlue900.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.tag_fill,
                    size: 16,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Top keyword',
                    style: AppTextStyles.metadata.copyWith(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  if (hasKeyword) ...[
                    const Spacer(),
                    Icon(
                      CupertinoIcons.search,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Text(
                hasKeyword ? keyword!.displayName : emptyLabel,
                style: AppTextStyles.h2.copyWith(
                  color: Colors.white,
                  fontSize: 17,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (hasKeyword && searchCount > 0) ...[
                const SizedBox(height: 6),
                Text(
                  searchCount == 1
                      ? 'Searched 1 time'
                      : 'Searched $searchCount times',
                  style: AppTextStyles.metadata.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactStatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _CompactStatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.brandBlue500),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.brandBlue900,
              fontSize: 22,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.metadata.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _KeywordStatsSkeleton extends StatelessWidget {
  const _KeywordStatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.white,
      child: Column(
        children: [
          Container(
            height: 108,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
