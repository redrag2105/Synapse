import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/config/test_keys.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/domain/entities/publication_entity.dart';
import 'package:synapse/presentation/controllers/publication_trend_controller.dart';
import 'package:synapse/presentation/screens/home/widgets/home_stat_card.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/publication_card.dart';
import 'package:synapse/presentation/screens/research_dashboard/research_dashboard_screen.dart';
import 'package:synapse/presentation/screens/trend/widgets/trend_line_chart.dart';
import 'package:synapse/presentation/widgets/pagination_footer.dart';

/// Live research-topic overview shown on Home after a successful search.
///
/// Built as a [SliverMainAxisGroup] so the dashboard stays one paint region
/// while publications are lazily built.
class HomeTopicOverview extends ConsumerWidget {
  final String topic;
  final List<PublicationEntity> publications;
  final bool hasReachedMax;

  const HomeTopicOverview({
    super.key,
    required this.topic,
    required this.publications,
    required this.hasReachedMax,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final influential = publications.isNotEmpty ? publications.first : null;
    final listPublications = publications.length > 1
        ? publications.sublist(1)
        : const <PublicationEntity>[];

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Overview dashboard for this research topic.',
                  style: AppTextStyles.metadata.copyWith(
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _HomeDashboardStats(
                  topic: topic,
                  publications: publications,
                  influential: influential,
                ),
                if (influential != null) ...[
                  const SizedBox(height: 28),
                  _InfluentialPublicationSection(publication: influential),
                ],
                if (listPublications.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Text(
                    'More publications',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap a publication to open details.',
                    style: AppTextStyles.metadata.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
        if (listPublications.isNotEmpty)
          SliverPadding(
            key: TestKeys.publicationResultsList,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: SliverList.builder(
              itemCount: listPublications.length + (hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= listPublications.length) {
                  return const PaginationLoadingIndicator();
                }
                final pub = listPublications[index];
                return PublicationCard(
                  key: ValueKey(pub.id),
                  publication: pub,
                  isLastItem:
                      index == listPublications.length - 1 && hasReachedMax,
                );
              },
            ),
          )
        else if (!hasReachedMax)
          const SliverToBoxAdapter(child: PaginationLoadingIndicator()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

/// Stats + chart isolated so author/journal/trend loads don't rebuild pub cards.
class _HomeDashboardStats extends ConsumerWidget {
  final String topic;
  final List<PublicationEntity> publications;
  final PublicationEntity? influential;

  const _HomeDashboardStats({
    required this.topic,
    required this.publications,
    required this.influential,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendState = ref.watch(publicationTrendControllerProvider);
    final authorState = ref.watch(dashboardTopAuthorProvider(topic));
    final journalState = ref.watch(dashboardTopJournalProvider(topic));

    final totalCitations = publications.fold<int>(
      0,
      (sum, p) => sum + p.citationCount,
    );
    final avgCitations = publications.isEmpty
        ? '—'
        : (totalCitations / publications.length).toStringAsFixed(1);

    final trendTotals = _TrendTotals.fromMap(trendState.asData?.value);
    final totalPubs = trendTotals.total > 0
        ? AppFormatters.formatNumber(trendTotals.total)
        : AppFormatters.formatNumber(publications.length);
    final peakYear = trendTotals.peakYear?.toString() ?? '—';
    final topAuthor = authorState.asData?.value?.displayName ?? '—';
    final topJournal = journalState.asData?.value?.displayName ?? '—';

    return Column(
      children: [
        RepaintBoundary(child: _TrendSection(trendState: trendState)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: HomeStatCard(
                icon: CupertinoIcons.doc_text,
                label: 'Total publications',
                value: trendState.isLoading ? '…' : totalPubs,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: HomeStatCard(
                icon: CupertinoIcons.quote_bubble,
                label: 'Avg. citations',
                value: avgCitations,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: HomeStatCard(
                icon: CupertinoIcons.calendar,
                label: 'Most active year',
                value: trendState.isLoading ? '…' : peakYear,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: HomeStatCard(
                icon: CupertinoIcons.person,
                label: 'Top author',
                value: authorState.isLoading ? '…' : topAuthor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: HomeStatCard(
                icon: CupertinoIcons.book,
                label: 'Top journal',
                value: journalState.isLoading ? '…' : topJournal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: HomeStatCard(
                icon: CupertinoIcons.star,
                label: 'Citations (top work)',
                value: influential == null
                    ? '—'
                    : AppFormatters.formatNumber(influential!.citationCount),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfluentialPublicationSection extends StatelessWidget {
  final PublicationEntity publication;

  const _InfluentialPublicationSection({required this.publication});

  @override
  Widget build(BuildContext context) {
    const radius = 16.0;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.brandGold.withValues(alpha: 0.55),
          width: 1.2,
        ),
        color: AppColors.brandGold.withValues(alpha: 0.06),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandBlue900.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue900,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.star_fill,
                          size: 12,
                          color: AppColors.brandGold,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'MOST INFLUENTIAL',
                          style: AppTextStyles.metadata.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${AppFormatters.formatNumber(publication.citationCount)} citations',
                    style: AppTextStyles.metadata.copyWith(
                      color: AppColors.brandBlue900,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            PublicationCard(
              key: TestKeys.firstPublicationCard,
              publication: publication,
              isLastItem: true,
              showCitationCount: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendTotals {
  final int total;
  final int? peakYear;

  const _TrendTotals({required this.total, required this.peakYear});

  factory _TrendTotals.fromMap(Map<int, int>? data) {
    if (data == null || data.isEmpty) {
      return const _TrendTotals(total: 0, peakYear: null);
    }
    var total = 0;
    var peakYear = data.keys.first;
    var peakCount = -1;
    data.forEach((year, count) {
      total += count;
      if (count > peakCount) {
        peakCount = count;
        peakYear = year;
      }
    });
    return _TrendTotals(total: total, peakYear: peakYear);
  }
}

class _TrendSection extends StatelessWidget {
  final AsyncValue<Map<int, int>> trendState;

  const _TrendSection({required this.trendState});

  @override
  Widget build(BuildContext context) {
    return trendState.when(
      loading: () => Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderGray.withValues(alpha: 0.6),
          ),
        ),
        child: const CupertinoActivityIndicator(),
      ),
      error: (_, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Unable to load publication trend.',
          style: AppTextStyles.metadata,
        ),
      ),
      data: (trendData) {
        if (trendData.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'No trend data for this topic yet.',
              style: AppTextStyles.metadata,
            ),
          );
        }

        final sortedYears = trendData.keys.toList()..sort();
        final currentYear = DateTime.now().year;
        final recentYears = sortedYears
            .where((y) => y >= currentYear - 20)
            .toList();
        final years = recentYears.length >= 2 ? recentYears : sortedYears;

        if (years.length < 2) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Not enough years to chart a trend.',
              style: AppTextStyles.metadata,
            ),
          );
        }

        double maxY = 0;
        final spots = <FlSpot>[];
        for (final year in years) {
          final count = trendData[year]!.toDouble();
          if (count > maxY) maxY = count;
          spots.add(FlSpot(year.toDouble(), count));
        }

        return TrendLineChart(
          spots: spots,
          minX: years.first.toDouble(),
          maxX: years.last.toDouble(),
          maxY: maxY == 0 ? 1 : maxY,
          title: 'Publication trend',
          subtitle: '${years.first} – ${years.last}',
          animate: false,
        );
      },
    );
  }
}
