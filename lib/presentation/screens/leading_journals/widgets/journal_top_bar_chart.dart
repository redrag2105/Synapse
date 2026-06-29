import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/domain/entities/leading_journal_entity.dart';

/// Section B — vertical bar ranking for the top 5 journals by article count.
class JournalTopBarChart extends StatelessWidget {
  final List<LeadingJournalEntity> journals;

  const JournalTopBarChart({super.key, required this.journals});

  static const double _leftAxisWidth = 44;

  @override
  Widget build(BuildContext context) {
    final topFive = journals.take(5).toList();
    if (topFive.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Top 5 by Article Volume',
            style: AppTextStyles.h3.copyWith(
              fontSize: 15,
              color: AppColors.brandBlue900,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 210,
            child: BarChart(
              _buildBarChartData(topFive),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: _leftAxisWidth),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(topFive.length, (index) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          _abbreviateLabel(topFive[index].name),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.metadata.copyWith(
                            fontSize: 9,
                            height: 1.25,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BarChartData _buildBarChartData(List<LeadingJournalEntity> topFive) {
    final maxCount = topFive
        .map((journal) => journal.articleCount)
        .reduce(math.max)
        .toDouble();
    final axis = _computeYAxis(maxCount);

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: axis.maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: axis.interval,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.borderGray,
          strokeWidth: 1,
          dashArray: const [4, 4],
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false, reservedSize: 0),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: _leftAxisWidth,
            interval: axis.interval,
            getTitlesWidget: (value, meta) {
              if (value <= 0 || value > axis.maxY + 0.001) {
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

  /// Short label for the row below the chart — full name is in the tooltip.
  String _abbreviateLabel(String name) {
    final stripped = AppFormatters.stripParenthetical(name);
    if (stripped.length <= 28) return stripped;
    return '${stripped.substring(0, 26)}…';
  }

  /// Picks a tight y-axis ceiling so bars fill the plot (no empty upper ticks).
  _YAxisScale _computeYAxis(double maxValue) {
    if (maxValue <= 0) {
      return const _YAxisScale(maxY: 10, interval: 2.5);
    }

    final padded = maxValue * 1.08;
    const targetTicks = 4;
    final interval = _niceStep(padded / targetTicks);
    final tickCount = (padded / interval).ceil().clamp(3, 5);
    final maxY = tickCount * interval;

    return _YAxisScale(maxY: maxY, interval: interval);
  }

  /// Smallest "nice" step that is >= [step] (1/2/2.5/5/10 × 10^n).
  double _niceStep(double step) {
    if (step <= 0) return 1;

    final exponent = (math.log(step) / math.ln10).floor();
    final base = math.pow(10, exponent).toDouble();
    const multipliers = [1.0, 2.0, 2.5, 5.0, 10.0];

    for (final multiplier in multipliers) {
      final candidate = multiplier * base;
      if (candidate >= step) return candidate;
    }

    return 10 * base;
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

class _YAxisScale {
  final double maxY;
  final double interval;

  const _YAxisScale({required this.maxY, required this.interval});
}
