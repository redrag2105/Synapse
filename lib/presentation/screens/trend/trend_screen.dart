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
import 'package:synapse/presentation/widgets/universal_header_delegate.dart';

class TrendScreen extends ConsumerStatefulWidget {
  final String? topicId;
  final String? topicName;

  const TrendScreen({super.key, this.topicId, this.topicName});

  @override
  ConsumerState<TrendScreen> createState() => _TrendScreenState();
}

class _TrendScreenState extends ConsumerState<TrendScreen>
    with SingleTickerProviderStateMixin {
  String _currentTitle = 'Global Research Publications';
  bool _isSearchBarFocused = false;
  late final AnimationController _focusAnimController;

  bool _isIsolatedMode = false;

  @override
  void initState() {
    super.initState();
    _focusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    final notifier = ref.read(publicationTrendControllerProvider.notifier);
    final hasNewArgs = widget.topicId != null || widget.topicName != null;
    final extKeyword = notifier.pendingExternalKeyword;
    final extTopicName = notifier.pendingExternalTopicName;

    if (extKeyword != null) {
      _isIsolatedMode = true;
      _currentTitle = extTopicName ?? extKeyword;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.fetchTrend(
          keyword: extKeyword,
          topicName: extTopicName,
          saveHistory: false,
        );
      });
      notifier.pendingExternalKeyword = null;
      notifier.pendingExternalTopicName = null;
    } else if (hasNewArgs) {
      _isIsolatedMode = true;
      _currentTitle = widget.topicName ?? 'Global Research Publications';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.fetchTrend(
          topicId: widget.topicId,
          topicName: widget.topicName,
          saveHistory: false,
        );
      });
    } else {
      _isIsolatedMode = false;
      final lastQuery = notifier.lastQuery;
      final lastTopicName = notifier.lastTopicName;

      if (lastTopicName != null || lastQuery.isNotEmpty) {
        _currentTitle = lastTopicName ?? lastQuery;
      } else {
        _currentTitle = 'Global Research Publications';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifier.fetchTrend(saveHistory: true);
        });
      }
    }
  }

  @override
  void dispose() {
    _focusAnimController.dispose();
    super.dispose();
  }

  void _handleSearch(String keyword, {String? topicId, String? topicName}) {
    final query = keyword.trim();
    final isGlobal = query.isEmpty && topicId == null;

    setState(() {
      if (isGlobal) {
        _currentTitle = 'Global Research Publications';
      } else {
        _currentTitle = topicName ?? query;
      }
      _isSearchBarFocused = false;
    });

    _focusAnimController.reverse();
    FocusManager.instance.primaryFocus?.unfocus();

    ref
        .read(publicationTrendControllerProvider.notifier)
        .fetchTrend(
          keyword: isGlobal ? null : (topicId == null ? query : null),
          topicId: topicId,
          topicName: topicName,
          saveHistory: !_isIsolatedMode,
        );
  }

  void _onFocusChanged(bool hasFocus) {
    _isSearchBarFocused = hasFocus;
    if (hasFocus) {
      _focusAnimController.forward();
    } else {
      _focusAnimController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final trendState = ref.watch(publicationTrendControllerProvider);
    final topPadding = MediaQuery.paddingOf(context).top;

    final isGlobal = _currentTitle == 'Global Research Publications';
    final initialSearchQuery = isGlobal ? '' : _currentTitle;

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        bottom: true,
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                AnimatedBuilder(
                  animation: _focusAnimController,
                  builder: (context, child) {
                    return SliverPersistentHeader(
                      pinned: true,
                      delegate: UniversalHeaderDelegate(
                        topPadding: topPadding,
                        title: 'Trend Analysis',
                        subtitle: _currentTitle,
                        searchBarInitialValue: initialSearchQuery,
                        searchBarHintText: 'Search topic to analyze trend...',
                        focusProgress: _focusAnimController.value,
                        onFocusChanged: _onFocusChanged,
                        onSubmitted: (keyword) => _handleSearch(keyword),
                        onTopicSelected: (topic) => _handleSearch(
                          topic.displayName,
                          topicId: topic.id,
                          topicName: topic.displayName,
                        ),
                      ),
                    );
                  },
                ),

                SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder:
                        (Widget? currentChild, List<Widget> previousChildren) {
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
                          return const TrendEmptyState(
                            key: ValueKey('trend_empty'),
                          );
                        }

                        final sortedYears = trendData.keys.toList()..sort();
                        final currentYear = DateTime.now().year;
                        final recentYears = sortedYears
                            .where((y) => y >= currentYear - 20)
                            .toList();

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
                              ((lastYearCount - prevYearCount) /
                                  prevYearCount) *
                              100;
                        }

                        final avgPerYear =
                            (totalPublications / recentYears.length).round();
                        String trendStatus = "Stable ⚖️";
                        Color trendColor = AppColors.textSecondary;
                        if (growthRate > 5) {
                          trendStatus = "Trending Up 🚀";
                          trendColor = AppColors.success;
                        } else if (growthRate < -5) {
                          trendStatus = "Downtrend 📉";
                          trendColor = AppColors.error;
                        }

                        final recent5Years = recentYears.length >= 5
                            ? recentYears.sublist(recentYears.length - 5)
                            : recentYears;
                        double total5YGrowth = 0;
                        int validYears = 0;
                        for (int i = 1; i < recent5Years.length; i++) {
                          int prev = trendData[recent5Years[i - 1]] ?? 0;
                          int curr = trendData[recent5Years[i]] ?? 0;
                          if (prev > 0) {
                            total5YGrowth += (curr - prev) / prev;
                            validYears++;
                          }
                        }
                        double avgYoY = validYears > 0
                            ? total5YGrowth / validYears
                            : 0;
                        int projectedNextYear =
                            ((trendData[recentYears.last] ?? 0) * (1 + avgYoY))
                                .round();
                        if (projectedNextYear < 0) projectedNextYear = 0;

                        return Padding(
                          key: const ValueKey('trend_data'),
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
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
                                      subtitle:
                                          '${minYear.toInt()} - ${maxYear.toInt()}',
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
                                    final keywordToPass = isGlobal
                                        ? '__ALL__'
                                        : _currentTitle;
                                    context.push(
                                      '${AppRoutes.dashboard}/${Uri.encodeComponent(keywordToPass)}',
                                    );
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
                                    elevation:
                                        0, // Bỏ bóng đổ để giữ thiết kế phẳng, hiện đại
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            AnimatedBuilder(
              animation: _focusAnimController,
              builder: (context, child) {
                final focusProgress = _focusAnimController.value;

                if (!_isSearchBarFocused && focusProgress == 0.0) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  top: (topPadding + 160.0) - (95.0 * focusProgress),
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    child: Opacity(
                      opacity: focusProgress,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
