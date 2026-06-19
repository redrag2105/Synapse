import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/domain/entities/leading_journal_entity.dart';

/// Donut chart showing journal portfolio split across impact quartiles.
class JournalQuartileDistributionChart extends StatelessWidget {
  final JournalQuartileDistribution distribution;

  const JournalQuartileDistributionChart({
    super.key,
    required this.distribution,
  });

  // Q1 (đậm) → Q4 (nhạt)
  static const Color _q1Color = AppColors.brandBlue900;
  static const Color _q2Color = AppColors.brandBlue700;
  static const Color _q3Color = AppColors.brandBlue600;
  static const Color _q4Color = Color(0xFF9EC5DC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUARTILE DISTRIBUTION',
            style: AppTextStyles.metadata.copyWith(
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Analysis of the portfolio journals ranked by impact tier quartiles',
            style: AppTextStyles.metadata.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Center(child: _buildDonutChart()),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildDonutChart() {
    final sections = [
      _section(distribution.q1Percent, _q1Color),
      _section(distribution.q2Percent, _q2Color),
      _section(distribution.q3Percent, _q3Color),
      _section(distribution.q4Percent, _q4Color),
    ];

    return SizedBox(
      height: 200,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 62,
              startDegreeOffset: -90,
              sections: sections,
            ),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${distribution.q1Percent.toInt()}%',
                style: AppTextStyles.h1.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandBlue900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Q1 RATIO',
                style: AppTextStyles.metadata.copyWith(
                  fontSize: 10,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _section(double value, Color color) {
    return PieChartSectionData(
      value: value,
      color: color,
      radius: 36,
      showTitle: false,
    );
  }

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        _legendItem('Q1', distribution.q1Percent, _q1Color),
        _legendItem('Q2', distribution.q2Percent, _q2Color),
        _legendItem('Q3', distribution.q3Percent, _q3Color),
        if (distribution.q4Percent > 0)
          _legendItem('Q4', distribution.q4Percent, _q4Color),
      ],
    );
  }

  Widget _legendItem(String label, double percent, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ${percent.toInt()}%',
          style: AppTextStyles.metadata.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
