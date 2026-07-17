import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/config/routes/app_routes.dart';
import 'package:synapse/domain/entities/author_entity.dart';
import 'package:synapse/domain/entities/journal_entity.dart';
import 'package:synapse/presentation/controllers/analytics_providers.dart';
import 'package:synapse/presentation/screens/keyword_detail/keyword_detail_providers.dart';
import 'package:synapse/presentation/screens/keyword_detail/widgets/author_publication_bar_chart.dart';
import 'package:synapse/presentation/screens/keyword_detail/widgets/keyword_detail_header_delegate.dart';
import 'package:synapse/presentation/screens/keyword_detail/widgets/related_journal_tile.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/publication_card.dart';
import 'package:synapse/presentation/screens/top_authors/widgets/author_rank_tile.dart';
import 'package:synapse/presentation/screens/trend/widgets/trend_line_chart.dart';

/// Analytical detail for a selected research keyword.
class KeywordDetailScreen extends ConsumerStatefulWidget {
  final String keyword;

  const KeywordDetailScreen({super.key, required this.keyword});

  @override
  ConsumerState<KeywordDetailScreen> createState() =>
      _KeywordDetailScreenState();
}

class _KeywordDetailScreenState extends ConsumerState<KeywordDetailScreen> {
  late final String _keyword;

  @override
  void initState() {
    super.initState();
    _keyword = widget.keyword == '__ALL__'
        ? ''
        : Uri.decodeComponent(widget.keyword);

    if (_keyword.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(analyticsServiceProvider).logViewKeyword(keyword: _keyword);
      });
    }
  }

  void _openAuthor(AuthorEntity author) {
    final authorId = author.id.split('/').last;
    final encoded = Uri.encodeComponent(_keyword);
    context.push('${AppRoutes.topAuthors}/$authorId?topic=$encoded');
  }

  void _openJournal(JournalEntity journal) {
    final journalId = journal.id.split('/').last;
    context.push(AppRoutes.journalDetail(journalId));
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final displayKeyword = _keyword.isEmpty ? 'All research' : _keyword;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: KeywordDetailHeaderDelegate(
              topPadding: topPadding,
              keyword: displayKeyword,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Analytical overview for this keyword: trends, journals, '
                'publications, and top contributing authors.',
                style: AppTextStyles.metadata.copyWith(
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _SectionLabel(
                title: 'Publication trends',
                subtitle: 'Works published over time for this keyword.',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            sliver: SliverToBoxAdapter(
              child: _TrendSection(keyword: _keyword),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _SectionLabel(
                title: 'Top contributing authors',
                subtitle:
                    'Ranked by number of publications for this keyword.',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            sliver: SliverToBoxAdapter(
              child: _AuthorsSection(
                keyword: _keyword,
                onAuthorTap: _openAuthor,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _SectionLabel(
                title: 'Related journals',
                subtitle: 'Venues with the most works for this keyword.',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            sliver: SliverToBoxAdapter(
              child: _JournalsSection(
                keyword: _keyword,
                onJournalTap: _openJournal,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _SectionLabel(
                title: 'Related publications',
                subtitle: 'Influential works associated with this keyword.',
              ),
            ),
          ),
          _PublicationsSection(keyword: _keyword),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionLabel({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.metadata.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _TrendSection extends ConsumerWidget {
  final String keyword;

  const _TrendSection({required this.keyword});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendState = ref.watch(keywordDetailTrendProvider(keyword));

    return trendState.when(
      loading: () => const _CardLoading(height: 280),
      error: (_, _) => const _InlineError(
        message: 'Unable to load publication trend.',
      ),
      data: (trendData) {
        if (trendData.isEmpty) {
          return const _InlineError(
            message: 'No trend data for this keyword yet.',
          );
        }

        final sortedYears = trendData.keys.toList()..sort();
        final currentYear = DateTime.now().year;
        final recentYears = sortedYears
            .where((y) => y >= currentYear - 20)
            .toList();
        final years = recentYears.length >= 2 ? recentYears : sortedYears;

        if (years.length < 2) {
          return const _InlineError(
            message: 'Not enough years to chart a trend.',
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
          title: 'Publication trend over time',
          subtitle: '${years.first} – ${years.last}',
          animate: false,
        );
      },
    );
  }
}

class _AuthorsSection extends ConsumerWidget {
  final String keyword;
  final void Function(AuthorEntity author) onAuthorTap;

  const _AuthorsSection({
    required this.keyword,
    required this.onAuthorTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authorsState = ref.watch(keywordDetailAuthorsProvider(keyword));

    return authorsState.when(
      loading: () => const _CardLoading(height: 200),
      error: (_, _) => const _InlineError(
        message: 'Unable to load author rankings.',
      ),
      data: (authors) {
        if (authors.isEmpty) {
          return const _InlineError(
            message: 'No contributing authors found for this keyword.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthorPublicationBarChart(
              authors: authors,
              onAuthorTap: onAuthorTap,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderGray),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < authors.length; i++)
                    AuthorRankTile(
                      rank: i + 1,
                      author: authors[i],
                      onTap: () => onAuthorTap(authors[i]),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _JournalsSection extends ConsumerWidget {
  final String keyword;
  final void Function(JournalEntity journal) onJournalTap;

  const _JournalsSection({
    required this.keyword,
    required this.onJournalTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalsState = ref.watch(keywordDetailJournalsProvider(keyword));

    return journalsState.when(
      loading: () => const _CardLoading(height: 160),
      error: (_, _) => const _InlineError(
        message: 'Unable to load related journals.',
      ),
      data: (journals) {
        if (journals.isEmpty) {
          return const _InlineError(
            message: 'No related journals found for this keyword.',
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderGray),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < journals.length; i++)
                RelatedJournalTile(
                  rank: i + 1,
                  journal: journals[i],
                  isLast: i == journals.length - 1,
                  onTap: () => onJournalTap(journals[i]),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PublicationsSection extends ConsumerWidget {
  final String keyword;

  const _PublicationsSection({required this.keyword});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pubsState = ref.watch(keywordDetailPublicationsProvider(keyword));

    return pubsState.when(
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _CardLoading(height: 120),
        ),
      ),
      error: (_, _) => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _InlineError(message: 'Unable to load related publications.'),
        ),
      ),
      data: (publications) {
        if (publications.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _InlineError(
                message: 'No related publications found for this keyword.',
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: SliverList.builder(
            itemCount: publications.length,
            itemBuilder: (context, index) {
              final pub = publications[index];
              return PublicationCard(
                key: ValueKey(pub.id),
                publication: pub,
                isLastItem: index == publications.length - 1,
              );
            },
          ),
        );
      },
    );
  }
}

class _CardLoading extends StatelessWidget {
  final double height;

  const _CardLoading({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderGray.withValues(alpha: 0.6),
        ),
      ),
      child: const CupertinoActivityIndicator(),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: AppTextStyles.metadata),
    );
  }
}
