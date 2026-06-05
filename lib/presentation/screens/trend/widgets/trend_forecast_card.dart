import 'package:flutter/cupertino.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/app_formatters.dart';

class TrendForecastCard extends StatelessWidget {
  final int projectedCount;
  final double averageYoY;
  final int nextYear;

  const TrendForecastCard({
    super.key,
    required this.projectedCount,
    required this.averageYoY,
    required this.nextYear,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = averageYoY >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brandBlue900.withValues(alpha: 0.001),
            AppColors.brandBlue700.withValues(alpha: 0.16),
          ],
          begin: Alignment.bottomRight,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.brandBlue600.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brandBlue900.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.chart_bar_alt_fill,
              color: AppColors.brandBlue900,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forecast for $nextYear',
                  style: AppTextStyles.metadata.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      AppFormatters.formatNumber(projectedCount),
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.brandBlue900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'papers',
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on a ${isPositive ? '+' : ''}${(averageYoY * 100).toStringAsFixed(1)}% 5-year avg growth',
                  style: AppTextStyles.metadata.copyWith(
                    color: isPositive ? AppColors.success : AppColors.error,
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
