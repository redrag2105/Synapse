import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/presentation/controllers/journal_detail_controller.dart';
import 'package:synapse/presentation/controllers/journal_publications_controller.dart';
import 'package:synapse/presentation/screens/journal_detail/widgets/journal_detail_content.dart';
import 'package:synapse/presentation/screens/journal_detail/widgets/journal_detail_header_delegate.dart';
import 'package:synapse/presentation/screens/journal_detail/widgets/journal_detail_skeleton.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/publication_card.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/publication_card_skeleton.dart';
import 'package:synapse/presentation/widgets/pagination_footer.dart';

class JournalDetailScreen extends ConsumerStatefulWidget {
  final String journalId;

  const JournalDetailScreen({super.key, required this.journalId});

  @override
  ConsumerState<JournalDetailScreen> createState() =>
      _JournalDetailScreenState();
}

class _JournalDetailScreenState extends ConsumerState<JournalDetailScreen> {
  late final ScrollController _scrollController;
  final ScrollPaginationLock _paginationLock = ScrollPaginationLock();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final metrics = _scrollController.position;
    _paginationLock.onScroll(metrics);

    final publicationsController = ref.read(
      journalPublicationsControllerProvider(widget.journalId).notifier,
    );
    final publicationsState = ref.read(
      journalPublicationsControllerProvider(widget.journalId),
    );

    if (!publicationsState.hasValue ||
        publicationsState.requireValue.isEmpty) {
      return;
    }

    _paginationLock.tryLoad(
      metrics: metrics,
      canLoadMore: !publicationsController.hasReachedMax,
      isLoadingMore: publicationsController.isFetchingNext,
      onLoadMore: publicationsController.loadMore,
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(journalDetailProvider(widget.journalId));
    final publicationsState = ref.watch(
      journalPublicationsControllerProvider(widget.journalId),
    );
    final publicationsController = ref.read(
      journalPublicationsControllerProvider(widget.journalId).notifier,
    );

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      body: SafeArea(
        top: false,
        bottom: true,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [...previousChildren, ?currentChild],
            );
          },
          child: detailState.when(
            loading: () => const JournalDetailSkeleton(
              key: ValueKey('journal_detail_loading'),
            ),
            error: (error, _) => SizedBox(
              key: const ValueKey('journal_detail_error'),
              height: MediaQuery.sizeOf(context).height,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load journal details.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(
                          journalDetailProvider(widget.journalId),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (journal) {
              final topPadding = MediaQuery.paddingOf(context).top;

              return ColoredBox(
                key: const ValueKey('journal_detail_data'),
                color: AppColors.surfaceGray,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: JournalDetailHeaderDelegate(
                        topPadding: topPadding,
                        displayName: journal.displayName,
                        publisher: journal.hostOrganizationName,
                        issnL: journal.issnL,
                        worksCount: journal.worksCount,
                        citedByCount: journal.citedByCount,
                        hIndex: journal.hIndex,
                        isOa: journal.isOa,
                        isInDoaj: journal.isInDoaj,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ColoredBox(
                        color: AppColors.surfaceGray,
                        child: JournalDetailContent(journal: journal),
                      ),
                    ),
                    ...publicationsState.when(
                      loading: () => [
                        SliverPadding(
                          padding: const EdgeInsets.only(top: 16, bottom: 40),
                          sliver: SliverList.builder(
                            itemCount: 5,
                            itemBuilder: _buildPublicationSkeleton,
                          ),
                        ),
                      ],
                      error: (error, _) => [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'Unable to load publications.',
                                style: AppTextStyles.metadata.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      data: (publications) {
                        if (publications.isEmpty) {
                          return [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Center(
                                  child: Text(
                                    'No publications found for this journal.',
                                    style: AppTextStyles.metadata.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ];
                        }

                        final hasReachedMax =
                            publicationsController.hasReachedMax;
                        final itemCount =
                            publications.length + (hasReachedMax ? 0 : 1);

                        return [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                              child: Text(
                                'Publications (${AppFormatters.formatNumber(journal.worksCount)})',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.brandBlue900,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.only(bottom: 40),
                            sliver: SliverList.builder(
                              itemCount: itemCount,
                              itemBuilder: (context, index) {
                                if (index == publications.length) {
                                  return const PaginationLoadingIndicator();
                                }

                                return PublicationCard(
                                  key: ValueKey(publications[index].id),
                                  publication: publications[index],
                                  isLastItem: index == publications.length - 1,
                                );
                              },
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

Widget _buildPublicationSkeleton(BuildContext context, int index) {
  return const PublicationCardSkeleton();
}
