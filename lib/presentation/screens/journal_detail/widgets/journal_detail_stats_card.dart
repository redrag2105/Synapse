import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/app_formatters.dart';

class JournalDetailStatsCard extends StatelessWidget {
  final int worksCount;
  final int citedByCount;
  final int hIndex;

  /// Padding (28) + stat row (~36).
  static const double layoutHeight = 78;

  /// Extra space for the drop shadow so parent clips don't cut it off.
  static const double shadowBleed = 25;

  static double get totalHeight => layoutHeight + shadowBleed;

  const JournalDetailStatsCard({
    super.key,
    required this.worksCount,
    required this.citedByCount,
    required this.hIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: layoutHeight,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGray),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandBlue900.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _HeaderStat(
                label: 'Works',
                value: AppFormatters.formatNumber(worksCount),
              ),
            ),
            _divider(),
            Expanded(
              child: _HeaderStat(
                label: 'Citations',
                value: AppFormatters.compactNumber(citedByCount.toDouble()),
              ),
            ),
            _divider(),
            Expanded(
              child: _HeaderStat(label: 'H-Index', value: '$hIndex'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 34, color: AppColors.borderGray);
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.h2.copyWith(
            fontSize: 18,
            color: AppColors.brandBlue900,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.metadata.copyWith(
            fontSize: 10,
            color: AppColors.textLight,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
