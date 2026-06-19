import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/domain/entities/leading_journal_entity.dart';

/// Section B — horizontal bar ranking for the top 5 journals by article count.
class JournalTopBarChart extends StatelessWidget {
  final List<LeadingJournalEntity> journals;

  const JournalTopBarChart({super.key, required this.journals});

  @override
  Widget build(BuildContext context) {
    final topFive = journals.take(5).toList();
    if (topFive.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top 5 by Article Volume',
            style: AppTextStyles.h3.copyWith(
              fontSize: 15,
              color: AppColors.brandBlue900,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              _buildBarChartData(topFive),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  BarChartData _buildBarChartData(List<LeadingJournalEntity> topFive) {
    final maxCount = topFive
        .map((journal) => journal.articleCount)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final maxY = maxCount * 1.15;

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.borderGray,
          strokeWidth: 1,
          dashArray: const [4, 4],
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            getTitlesWidget: (value, meta) {
              if (value <= 0 || value > maxY) {
                return const SizedBox.shrink();
              }
              return Text(
                AppFormatters.compactNumber(value),
                style: AppTextStyles.metadata.copyWith(
                  fontSize: 10,
                  color: AppColors.textLight,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 52,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= topFive.length) {
                return const SizedBox.shrink();
              }

              return SideTitleWidget(
                meta: meta,
                space: 6,
                child: Text(
                  _wrapJournalLabel(topFive[index].name),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.metadata.copyWith(
                    fontSize: 9,
                    color: AppColors.textLight,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => AppColors.brandBlue900,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final journal = topFive[group.x];
            return BarTooltipItem(
              '${journal.name}\n',
              AppTextStyles.metadata.copyWith(color: Colors.white70),
              children: [
                TextSpan(
                  text: AppFormatters.formatNumber(journal.articleCount),
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      barGroups: List.generate(topFive.length, (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: topFive[index].articleCount.toDouble(),
              width: 18,
              color: AppColors.brandBlue900,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Break long journal names into two lines for the X axis.
  String _wrapJournalLabel(String name) {
    if (name.length <= 14) return name;

    final splitAt = name.lastIndexOf(' ', 14);
    if (splitAt > 0) {
      return '${name.substring(0, splitAt)}\n${name.substring(splitAt + 1)}';
    }

    return '${name.substring(0, 12)}\n${name.substring(12)}';
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
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
    );
  }
}
