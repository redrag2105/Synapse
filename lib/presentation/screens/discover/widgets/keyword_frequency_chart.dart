import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/domain/entities/keyword_entity.dart';

class KeywordFrequencyChart extends StatelessWidget {
  final List<KeywordEntity> keywords;
  final void Function(KeywordEntity keyword)? onKeywordTap;

  const KeywordFrequencyChart({
    super.key,
    required this.keywords,
    this.onKeywordTap,
  });

  @override
  Widget build(BuildContext context) {
    if (keywords.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxCount = keywords
        .map((k) => k.worksCount)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequency Distribution',
            style: AppTextStyles.h3.copyWith(
              fontSize: 14,
              color: AppColors.brandBlue900,
            ),
          ),
          const SizedBox(height: 16),
          ...keywords.map(
            (keyword) => _KeywordBarRow(
              keyword: keyword,
              maxCount: maxCount,
              onTap: onKeywordTap != null
                  ? () => onKeywordTap!(keyword)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeywordBarRow extends StatelessWidget {
  final KeywordEntity keyword;
  final int maxCount;
  final VoidCallback? onTap;

  const _KeywordBarRow({
    required this.keyword,
    required this.maxCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = maxCount > 0 ? keyword.worksCount / maxCount : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    keyword.displayName,
                    style: AppTextStyles.button.copyWith(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppFormatters.formatNumber(keyword.worksCount),
                  style: AppTextStyles.metadata.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: AppColors.surfaceGray,
                color: AppColors.brandBlue500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KeywordFrequencySkeleton extends StatelessWidget {
  const KeywordFrequencySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
      ),
    );
  }
}
