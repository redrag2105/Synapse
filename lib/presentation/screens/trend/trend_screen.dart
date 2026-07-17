import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/routes/app_routes.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/presentation/controllers/publication_trend_controller.dart';
import 'package:synapse/presentation/screens/trend/widgets/metric_card.dart';
import 'package:synapse/presentation/screens/trend/widgets/trend_empty_state.dart';
import 'package:synapse/presentation/screens/trend/widgets/trend_insight_card.dart';
import 'package:synapse/presentation/screens/trend/widgets/trend_line_chart.dart';
import 'package:synapse/presentation/screens/trend/widgets/trend_skeleton.dart';
import 'package:synapse/presentation/screens/trend/widgets/trend_small_stat_box.dart';
import 'package:synapse/presentation/screens/trend/widgets/trend_forecast_card.dart';
import 'package:synapse/presentation/screens/trend/widgets/trend_header_delegate.dart';

/// Full-screen trend analysis for a research topic opened from Home.
class TrendScreen extends ConsumerStatefulWidget {
  final String? topicId;
  final String? topicName;

  const TrendScreen({super.key, this.topicId, this.topicName});

  @override
  ConsumerState<TrendScreen> createState() => _TrendScreenState();
}

class _TrendScreenState extends ConsumerState<TrendScreen> {
  late String _currentTitle;

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(publicationTrendControllerProvider.notifier);
    _currentTitle = widget.topicName?.trim().isNotEmpty == true
        ? widget.topicName!.trim()
        : (notifier.lastTopicName ??
            (notifier.lastQuery.isNotEmpty
                ? notifier.lastQuery
                : 'Research Trend'));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasArgs = widget.topicId != null ||
          (widget.topicName != null && widget.topicName!.trim().isNotEmpty);
      if (hasArgs) {
        notifier.fetchTrend(
          topicId: widget.topicId,
          keyword: widget.topicName,
          topicName: widget.topicName,
          saveHistory: false,
        );
        return;
      }

      if (notifier.lastTopicName != null || notifier.lastQuery.isNotEmpty) {
        setState(() {
          _currentTitle = notifier.lastTopicName ?? notifier.lastQuery;
        });
        return;
      }

      notifier.fetchTrend(saveHistory: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final trendState = ref.watch(publicationTrendControllerProvider);
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: TrendHeaderDelegate(
              topPadding: topPadding,
              subtitle: _currentTitle,
            ),
          ),
          _TrendBody(trendState: trendState, topicTitle: _currentTitle),
        ],
      ),
    );
  }
}

class _TrendBody extends StatelessWidget {
  final AsyncValue<Map<int, int>> trendState;
  final String topicTitle;

  const _TrendBody({
    required this.trendState,
    required this.topicTitle,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              ...previousChildren,
              ?currentChild,
            ],
          );
        },
        child: trendState.when(
          loading: () =>
              const TrendSkeleton(key: ValueKey('trend_loading')),
          error: (err, stack) => SizedBox(
            key: const ValueKey('trend_error'),
            height: 400,
            child: Center(child: Text('Error: ${err.toString()}')),
          ),
          data: (trendData) {
            if (trendData.isEmpty) {
              return const TrendEmptyState(key: ValueKey('trend_empty'));
            }

            final sortedYears = trendData.keys.toList()..sort();
            final currentYear = DateTime.now().year;
            final recentYears =
                sortedYears.where((y) => y >= currentYear - 20).toList();

            if (recentYears.length < 2) {
              return const TrendEmptyState(
                key: ValueKey('trend_not_enough_data'),
              );
            }

            final minYear = recentYears.first.toDouble();
            final maxYear = recentYears.last.toDouble();
            double maxYValue = 0;
            int totalPublications = 0;
            int peakYear = recentYears.first;

            final spots = <FlSpot>[];
            for (final year in recentYears) {
              final count = trendData[year]!.toDouble();
              if (count > maxYValue) {
                maxYValue = count;
                peakYear = year;
              }
              totalPublications += count.toInt();
              spots.add(FlSpot(year.toDouble(), count));
            }

            final lastYear = recentYears.last;
            final prevYear = recentYears.length > 1
                ? recentYears[recentYears.length - 2]
                : lastYear;
            final lastYearCount = trendData[lastYear] ?? 0;
            final prevYearCount = trendData[prevYear] ?? 0;

            double growthRate = 0;
            if (prevYearCount > 0) {
              growthRate =
                  ((lastYearCount - prevYearCount) / prevYearCount) * 100;
            }

            final avgPerYear =
                (totalPublications / recentYears.length).round();
            String trendStatus = 'Stable';
            Color trendColor = AppColors.textSecondary;
            if (growthRate > 5) {
              trendStatus = 'Trending Up';
              trendColor = AppColors.success;
            } else if (growthRate < -5) {
              trendStatus = 'Downtrend';
              trendColor = AppColors.error;
            }

            final recent5Years = recentYears.length >= 5
                ? recentYears.sublist(recentYears.length - 5)
                : recentYears;
            double total5YGrowth = 0;
            int validYears = 0;
            for (int i = 1; i < recent5Years.length; i++) {
              final prev = trendData[recent5Years[i - 1]] ?? 0;
              final curr = trendData[recent5Years[i]] ?? 0;
              if (prev > 0) {
                total5YGrowth += (curr - prev) / prev;
                validYears++;
              }
            }
            final avgYoY = validYears > 0 ? total5YGrowth / validYears : 0.0;
            var projectedNextYear =
                ((trendData[recentYears.last] ?? 0) * (1 + avgYoY)).round();
            if (projectedNextYear < 0) projectedNextYear = 0;

            return Padding(
              key: const ValueKey('trend_data'),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          title: 'Total Volume',
                          value: AppFormatters.compactNumber(
                            totalPublications.toDouble(),
                          ),
                          subtitle: '${minYear.toInt()} - ${maxYear.toInt()}',
                          icon: CupertinoIcons.doc_on_doc,
                          color: AppColors.brandBlue900,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MetricCard(
                          title: 'Momentum',
                          value:
                              '${growthRate > 0 ? '+' : ''}${growthRate.toStringAsFixed(1)}%',
                          subtitle: 'vs previous year',
                          icon: growthRate >= 0
                              ? CupertinoIcons.arrow_up_right
                              : CupertinoIcons.arrow_down_right,
                          color: growthRate >= 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TrendLineChart(
                    spots: spots,
                    minX: minYear,
                    maxX: maxYear,
                    maxY: maxYValue,
                  ),
                  const SizedBox(height: 16),
                  TrendInsightCard(
                    peakYear: peakYear,
                    formattedPeakCount: AppFormatters.formatNumber(
                      trendData[peakYear]!,
                    ),
                    growthRate: growthRate,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Performance Breakdown',
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 16,
                      color: AppColors.brandBlue900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TrendSmallStatBox(
                          title: 'Average / Year',
                          value: AppFormatters.compactNumber(
                            avgPerYear.toDouble(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TrendSmallStatBox(
                          title: 'Current Status',
                          value: trendStatus,
                          valueColor: trendColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TrendForecastCard(
                    projectedCount: projectedNextYear,
                    averageYoY: avgYoY,
                    nextYear: lastYear + 1,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push(AppRoutes.keywordDetail(topicTitle));
                      },
                      icon: const Icon(
                        CupertinoIcons.square_grid_2x2_fill,
                        size: 20,
                      ),
                      label: Text(
                        'View Full Research Dashboard',
                        style: AppTextStyles.button.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandBlue900,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
