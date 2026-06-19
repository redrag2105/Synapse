import 'package:flutter/cupertino.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';

class TrendInsightCard extends StatelessWidget {
  final int peakYear;
  final String formattedPeakCount;
  final double growthRate;

  const TrendInsightCard({
    super.key,
    required this.peakYear,
    required this.formattedPeakCount,
    required this.growthRate,
  });

  @override
  Widget build(BuildContext context) {
    final isGrowth = growthRate >= 0;
    final momentumText = isGrowth ? "growth" : "decline";

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
          color: AppColors.brandBlue900.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.lightbulb_fill,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Key Insight',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 15,
                    color: AppColors.brandBlue900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Research volume reached its historical peak in $peakYear with $formattedPeakCount publications. The recent momentum shows a $momentumText of ${growthRate.abs().toStringAsFixed(1)}%.',
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary,
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
