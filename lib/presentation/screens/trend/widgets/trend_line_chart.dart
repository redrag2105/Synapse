import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/app_formatters.dart';

class TrendLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final double minX;
  final double maxX;
  final double maxY;

  const TrendLineChart({
    super.key,
    required this.spots,
    required this.minX,
    required this.maxX,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.only(top: 20, bottom: 12, left: 12, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 20.0),
            child: Text(
              'Publication Trend over Time',
              style: AppTextStyles.h3.copyWith(
                fontSize: 15,
                color: AppColors.brandBlue900,
              ),
            ),
          ),
          SizedBox(
            height: 250,
            child: LineChart(
              _buildChartData(),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData() {
    double rawMaxY = maxY + (maxY * 0.15);
    double rawInterval = rawMaxY / 4;
    double yInterval = rawInterval > 1000
        ? (rawInterval / 1000).ceil() * 1000.0
        : rawInterval > 100
        ? (rawInterval / 100).ceil() * 100.0
        : rawInterval.ceilToDouble();

    if (yInterval == 0) yInterval = 1;
    double finalMaxY = yInterval * 4;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: yInterval,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.borderGray,
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 52,
            interval: yInterval,
            getTitlesWidget: (value, meta) {
              if (value == 0 || value > finalMaxY) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  AppFormatters.compactNumber(value),
                  style: AppTextStyles.metadata.copyWith(
                    color: AppColors.textLight,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.right,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final year = value.toInt();
              final minYear = minX.toInt();
              final maxYear = maxX.toInt();

              if (value != year.toDouble()) return const SizedBox.shrink();

              int totalYears = maxYear - minYear;
              int dynamicStep = (totalYears / 4).ceil();
              if (dynamicStep < 2) dynamicStep = 2;

              bool shouldRender = false;

              if (year == minYear || year == maxYear) {
                shouldRender = true;
              } else if ((year - minYear) % dynamicStep == 0) {
                if ((year - minYear) >= 3 && (maxYear - year) >= 3) {
                  shouldRender = true;
                }
              }

              if (!shouldRender) return const SizedBox.shrink();

              return SideTitleWidget(
                meta: meta,
                space: 8.0,
                child: Text(
                  year.toString(),
                  style: AppTextStyles.metadata.copyWith(
                    color: AppColors.textLight,
                    fontSize: 11,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: minX,
      maxX: maxX,
      minY: 0,
      maxY: finalMaxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.brandBlue900,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.brandBlue900.withValues(alpha: 0.3),
                AppColors.brandBlue900.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: AppColors.brandBlue900.withValues(alpha: 0.5),
                    strokeWidth: 2,
                    dashArray: [4, 4],
                  ),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: AppColors.brandBlue900,
                        ),
                  ),
                );
              }).toList();
            },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => AppColors.brandBlue900,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              return LineTooltipItem(
                '${touchedSpot.x.toInt()}\n',
                AppTextStyles.metadata.copyWith(color: Colors.white70),
                children: [
                  TextSpan(
                    text: AppFormatters.formatNumber(touchedSpot.y.toInt()),
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
