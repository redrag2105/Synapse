import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/routes/app_routes.dart';
import 'package:synapse/app/config/test_keys.dart';
import 'package:synapse/presentation/controllers/publication_search_controller.dart';
import 'package:synapse/presentation/controllers/tab_bar_ui_controller.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/publication_card.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/publication_card_skeleton.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/research_insights_fab.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/search_empty_state.dart';
import 'package:synapse/presentation/widgets/pagination_footer.dart';
import 'package:synapse/presentation/widgets/universal_header_delegate.dart';
import 'package:synapse/presentation/widgets/navigation/app_bottom_nav_layout.dart';
import 'package:synapse/presentation/widgets/navigation/tab_screen_scaffold.dart';

class PublicationSearchScreen extends ConsumerStatefulWidget {
  const PublicationSearchScreen({super.key});

  @override
  ConsumerState<PublicationSearchScreen> createState() =>
      _PublicationSearchScreenState();
}

class _PublicationSearchScreenState
    extends ConsumerState<PublicationSearchScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool _isFocused = false;
  late final AnimationController _focusAnimController;
  late final TabBarSuppressedNotifier _tabBarSuppressedNotifier;

  final ScrollController _scrollController = ScrollController();
  final ScrollPaginationLock _paginationLock = ScrollPaginationLock();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabBarSuppressedNotifier = ref.read(tabBarSuppressedProvider.notifier);
    _focusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final metrics = _scrollController.position;
    _paginationLock.onScroll(metrics);

    final controller = ref.read(publicationSearchControllerProvider.notifier);
    final searchState = ref.read(publicationSearchControllerProvider);

    if (controller.lastQuery.isEmpty ||
        !searchState.hasValue ||
        searchState.requireValue.isEmpty) {
      return;
    }

    _paginationLock.tryLoad(
      metrics: metrics,
      canLoadMore: !controller.hasReachedMax,
      isLoadingMore: controller.isFetchingNext,
      onLoadMore: controller.loadMore,
    );
  }

  @override
  void dispose() {
    _tabBarSuppressedNotifier.setSuppressed(false);
    _focusAnimController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onFocusChanged(bool hasFocus) {
    if (_isFocused == hasFocus) return;
    setState(() => _isFocused = hasFocus);
    updateTabBarSuppressed(ref, hasFocus);
    if (hasFocus) {
      _focusAnimController.forward();
    } else {
      _focusAnimController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final searchState = ref.watch(publicationSearchControllerProvider);
    final controller = ref.read(publicationSearchControllerProvider.notifier);

    final topPadding = MediaQuery.paddingOf(context).top;
    final lastQuery = controller.lastQuery;
    final tabBarInset = AppBottomNavLayout.maxOverlayInset(
      MediaQuery.paddingOf(context).bottom,
    );
    final showInsightsFab = !_isFocused &&
        lastQuery.isNotEmpty &&
        !(searchState.isLoading && !searchState.hasValue);
    final isSearchTabActive =
        ref.watch(shellTabIndexProvider) == ShellTabIndex.search;

    return TabScreenScaffold(
      body: ColoredBox(
        color: AppColors.background,
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                AnimatedBuilder(
                  animation: _focusAnimController,
                  builder: (context, child) {
                    return SliverPersistentHeader(
                      pinned: true,
                      floating: true,
                      delegate: UniversalHeaderDelegate(
                        showBackButton: false,
                        restoreOnEmptySubmit: true,
                        topPadding: topPadding,
                        title: 'Search Publications',
                        subtitle: lastQuery.isEmpty
                            ? 'Discover Scholarly Works'
                            : lastQuery,
                        searchBarInitialValue: lastQuery,
                        searchBarHintText: 'Search for topics...',
                        searchFieldKey: TestKeys.publicationSearchField,
                        focusProgress: _focusAnimController.value,
                        onFocusChanged: _onFocusChanged,
                        onSubmitted: (query) {
                          _paginationLock.reset();
                          ref
                              .read(
                                publicationSearchControllerProvider.notifier,
                              )
                              .search(query);
                        },
                        onTopicSelected: (topic) {
                          _paginationLock.reset();
                          ref
                              .read(
                                publicationSearchControllerProvider.notifier,
                              )
                              .searchByTopicId(topic);
                        },
                      ),
                    );
                  },
                ),

                ...searchState.when(
                  loading: () => [
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 16, bottom: 40),
                      sliver: SliverList.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) =>
                            const PublicationCardSkeleton(),
                      ),
                    ),
                  ],

                  error: (error, stack) => [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('Lỗi: ${error.toString()}')),
                    ),
                  ],

                  data: (publications) {
                    if (publications.isEmpty) {
                      return [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: lastQuery.isEmpty
                                ? const SearchEmptyState(
                                    key: ValueKey('initial_state'),
                                    isInitialState: true,
                                    icon: CupertinoIcons.book,
                                    title: 'Discover the Unknown',
                                    subtitle:
                                        'Search across millions of scholarly works, authors, and topics to start your research.',
                                  )
                                : SearchEmptyState(
                                    key: const ValueKey('no_results_state'),
                                    isInitialState: false,
                                    icon: CupertinoIcons.search,
                                    title: 'No results found',
                                    subtitle:
                                        'We couldn\'t find anything matching "$lastQuery".\nTry checking your spelling or use broader terms.',
                                  ),
                          ),
                        ),
                      ];
                    }

                    final hasReachedMax = controller.hasReachedMax;
                    final itemCount =
                        publications.length + (hasReachedMax ? 0 : 1);

                    return [
                      SliverPadding(
                        key: TestKeys.publicationResultsList,
                        padding: const EdgeInsets.only(top: 16, bottom: 40),
                        sliver: SliverList.builder(
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                            if (index == publications.length) {
                              return const PaginationLoadingIndicator();
                            }

                            return PublicationCard(
                              key: index == 0
                                  ? TestKeys.firstPublicationCard
                                  : ValueKey(publications[index].id),
                              publication: publications[index],
                              isLastItem: index == publications.length - 1,
                            );
                          },
                        ),
                      ),
                    ];
                  },
                ),
                const SliverToBoxAdapter(child: TabBarContentPadding()),
              ],
            ),

            AnimatedBuilder(
              animation: _focusAnimController,
              builder: (context, child) {
                final focusProgress = _focusAnimController.value;

                if (!_isFocused && focusProgress == 0.0) {
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

            if (showInsightsFab)
              Positioned.fill(
                child: ResearchInsightsFab(
                  tabBarInset: tabBarInset,
                  keyword: lastQuery,
                  screenActive: isSearchTabActive,
                  onTrend: () {
                    ref
                        .read(shellKeywordIntentProvider.notifier)
                        .dispatch(ShellTabIndex.trend, lastQuery);
                    context.go(AppRoutes.trend);
                  },
                  onAuthors: () {
                    ref
                        .read(shellKeywordIntentProvider.notifier)
                        .dispatch(ShellTabIndex.authors, lastQuery);
                    context.go(AppRoutes.authors);
                  },
                  onJournals: () {
                    ref
                        .read(shellKeywordIntentProvider.notifier)
                        .dispatch(ShellTabIndex.journals, lastQuery);
                    context.go(AppRoutes.journals);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
