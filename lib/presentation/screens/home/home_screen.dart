import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/routes/app_routes.dart';
import 'package:synapse/app/config/test_keys.dart';
import 'package:synapse/domain/entities/topic_entity.dart';
import 'package:synapse/presentation/controllers/auth_providers.dart';
import 'package:synapse/presentation/controllers/keyword_history_providers.dart';
import 'package:synapse/presentation/controllers/publication_search_controller.dart';
import 'package:synapse/presentation/controllers/publication_trend_controller.dart';
import 'package:synapse/presentation/controllers/tab_bar_ui_controller.dart';
import 'package:synapse/presentation/screens/discover/widgets/discover_header_delegate.dart';
import 'package:synapse/presentation/screens/home/widgets/home_keyword_history_section.dart';
import 'package:synapse/presentation/screens/home/widgets/home_search_bar_delegate.dart';
import 'package:synapse/presentation/screens/home/widgets/home_topic_overview.dart';
import 'package:synapse/presentation/screens/home/widgets/home_topic_overview_skeleton.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/search_empty_state.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/smart_trend_button.dart';
import 'package:synapse/presentation/widgets/pagination_footer.dart';
import 'package:synapse/presentation/widgets/navigation/app_bottom_nav_layout.dart';
import 'package:synapse/presentation/widgets/navigation/center_fab_button.dart';
import 'package:synapse/presentation/widgets/navigation/tab_screen_scaffold.dart';

/// Center Home tab — topic search and research overview dashboard.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool _isFocused = false;
  late final AnimationController _focusAnimController;
  late final TabBarSuppressedNotifier _tabBarSuppressedNotifier;

  final ScrollController _scrollController = ScrollController();
  final ScrollPaginationLock _paginationLock = ScrollPaginationLock();
  final ValueNotifier<bool> _isTrendButtonExpanded = ValueNotifier(true);

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

    final direction = metrics.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      if (_isTrendButtonExpanded.value) _isTrendButtonExpanded.value = false;
    } else if (direction == ScrollDirection.forward) {
      if (!_isTrendButtonExpanded.value) _isTrendButtonExpanded.value = true;
    }

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

  void _clearSearch() {
    _paginationLock.reset();
    ref.read(publicationSearchControllerProvider.notifier).search('');
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _runSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _clearSearch();
      return;
    }

    _paginationLock.reset();
    ref.read(publicationSearchControllerProvider.notifier).search(trimmed);
    ref
        .read(publicationTrendControllerProvider.notifier)
        .fetchTrend(keyword: trimmed, topicName: trimmed, saveHistory: false);
    ref.read(keywordHistoryProvider.notifier).record(keyword: trimmed);
  }

  void _runTopicSearch(TopicEntity topic) {
    _paginationLock.reset();
    ref
        .read(publicationSearchControllerProvider.notifier)
        .searchByTopicId(topic);
    ref
        .read(publicationTrendControllerProvider.notifier)
        .fetchTrend(
          topicId: topic.id,
          keyword: topic.displayName,
          topicName: topic.displayName,
          saveHistory: false,
        );
    ref.read(keywordHistoryProvider.notifier).record(
          keyword: topic.displayName,
          topicId: topic.id.split('/').last,
        );
  }

  @override
  void dispose() {
    _tabBarSuppressedNotifier.setSuppressed(false);
    _focusAnimController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _isTrendButtonExpanded.dispose();
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

  void _openTrend(String keyword) {
    final query = keyword.trim();
    if (query.isEmpty) return;
    ref
        .read(publicationTrendControllerProvider.notifier)
        .fetchTrend(keyword: query, topicName: query, saveHistory: false);
    context.push('${AppRoutes.trend}?keyword=${Uri.encodeComponent(query)}');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final searchState = ref.watch(publicationSearchControllerProvider);
    final controller = ref.read(publicationSearchControllerProvider.notifier);
    final user = ref.watch(currentUserProvider);
    // Keep history controller warm while signed in so searches update it live.
    if (user != null) {
      ref.watch(keywordHistoryProvider);
    }

    final media = MediaQuery.of(context);
    final topPadding = media.padding.top;
    final keyboardInset = media.viewInsets.bottom;
    final lastQuery = controller.lastQuery;
    final tabBarInset = AppBottomNavLayout.maxOverlayInset(
      media.padding.bottom,
    );
    final showTrendButton =
        !_isFocused &&
        lastQuery.isNotEmpty &&
        !(searchState.isLoading && !searchState.hasValue);

    final headerMax = topPadding + 220.0;
    final headerMin = topPadding + 60.0;
    final searchBarHeight = HomeSearchBarDelegate.barHeight;
    final trendButtonBottom = tabBarInset + CenterFabButton.fabLift - 18;

    return TabScreenScaffold(
      key: TestKeys.homeScreen,
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
                  builder: (context, _) {
                    return SliverPersistentHeader(
                      pinned: true,
                      delegate: DiscoverHeaderDelegate(
                        topPadding: topPadding,
                        focusProgress: _focusAnimController.value,
                        onProfileTap: () => context.go(AppRoutes.profile),
                        isSignedIn: user != null,
                        profilePhotoUrl: user?.photoURL,
                        profileDisplayName: user?.displayName,
                        profileEmail: user?.email,
                      ),
                    );
                  },
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: HomeSearchBarDelegate(
                    initialValue: lastQuery,
                    searchFieldKey: TestKeys.publicationSearchField,
                    onFocusChanged: _onFocusChanged,
                    onSubmitted: _runSearch,
                    onTopicSelected: _runTopicSearch,
                  ),
                ),
                ...searchState.when(
                  loading: () => [
                    const HomeTopicOverviewSkeleton(),
                  ],
                  error: (error, stack) => [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('Lỗi: ${error.toString()}')),
                    ),
                  ],
                  data: (publications) {
                    if (publications.isEmpty) {
                      if (lastQuery.isEmpty) {
                        return [
                          SliverToBoxAdapter(
                            child: HomeKeywordHistorySection(
                              onKeywordTap: _runSearch,
                            ),
                          ),
                        ];
                      }
                      return [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: SearchEmptyState(
                            key: const ValueKey('no_results_state'),
                            isInitialState: false,
                            icon: CupertinoIcons.search,
                            title: 'No results found',
                            subtitle:
                                'We couldn\'t find anything matching "$lastQuery".\nTry checking your spelling or use broader terms.',
                          ),
                        ),
                      ];
                    }

                    return [
                      HomeTopicOverview(
                        topic: lastQuery,
                        publications: publications,
                        hasReachedMax: controller.hasReachedMax,
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

                final headerExtent =
                    headerMax - (headerMax - headerMin) * focusProgress;
                final overlayTop = headerExtent + searchBarHeight;

                return Positioned(
                  top: overlayTop,
                  left: 0,
                  right: 0,
                  bottom: keyboardInset,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                    child: Opacity(
                      opacity: focusProgress,
                      child: const ColoredBox(color: Color(0x80000000)),
                    ),
                  ),
                );
              },
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              left: 16,
              right: 16,
              bottom: showTrendButton ? trendButtonBottom : -120,
              child: RepaintBoundary(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isTrendButtonExpanded,
                  builder: (context, isExpanded, _) {
                    return AnimatedAlign(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      alignment: isExpanded
                          ? Alignment.bottomCenter
                          : Alignment.bottomRight,
                      child: SmartTrendButton(
                        keyword: lastQuery,
                        isExpanded: isExpanded,
                        onTap: () => _openTrend(lastQuery),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
