import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:synapse/domain/entities/journal_detail_entity.dart';
import 'package:synapse/presentation/screens/trend/widgets/trend_line_chart.dart';

class JournalActivityChart extends StatelessWidget {
  final List<JournalYearCount> countsByYear;

  const JournalActivityChart({super.key, required this.countsByYear});

  @override
  Widget build(BuildContext context) {
    if (countsByYear.length < 2) {
      return const SizedBox.shrink();
    }

    final currentYear = DateTime.now().year;
    final recent = countsByYear
        .where((entry) => entry.year >= currentYear - 15)
        .toList();
    if (recent.length < 2) return const SizedBox.shrink();

    final spots = recent
        .map(
          (entry) => FlSpot(entry.year.toDouble(), entry.worksCount.toDouble()),
        )
        .toList();
    final minX = recent.first.year.toDouble();
    final maxX = recent.last.year.toDouble();
    final maxY = recent
        .map((entry) => entry.worksCount)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return TrendLineChart(
      spots: spots,
      minX: minX,
      maxX: maxX,
      maxY: maxY,
      title: 'Publication Activity',
      subtitle: 'Works published per year',
    );
  }
}
