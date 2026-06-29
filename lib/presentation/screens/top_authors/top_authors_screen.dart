import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/config/routes/app_routes.dart';
import 'package:synapse/presentation/controllers/top_author_controller.dart';
import 'package:synapse/presentation/screens/top_authors/widgets/author_rank_tile.dart';
import 'package:synapse/presentation/screens/top_authors/widgets/author_topic_heatmap.dart';
import 'package:synapse/presentation/screens/top_authors/widgets/global_author_insights_row.dart';
import 'package:synapse/presentation/screens/top_authors/widgets/top_authors_empty_state.dart';
import 'package:synapse/presentation/screens/top_authors/widgets/top_authors_skeleton.dart';
import 'package:synapse/presentation/widgets/pagination_footer.dart';
import 'package:synapse/presentation/widgets/universal_header_delegate.dart';
import 'package:synapse/presentation/widgets/navigation/app_bottom_nav_layout.dart';
import 'package:synapse/presentation/widgets/navigation/tab_screen_scaffold.dart';

class TopAuthorsScreen extends ConsumerStatefulWidget {
  const TopAuthorsScreen({super.key});

  @override
  ConsumerState<TopAuthorsScreen> createState() => _TopAuthorsScreenState();
}

class _TopAuthorsScreenState extends ConsumerState<TopAuthorsScreen>
    with SingleTickerProviderStateMixin {
  static const String _globalTitle = 'Global Top Researchers';

  late final AnimationController _focusAnimController;
  late final ScrollController _scrollController;
  String _currentTitle = _globalTitle;
  bool _isPaging = false;
  bool _isSearchBarFocused = false;

  @override
  void initState() {
    super.initState();
    _focusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scrollController = ScrollController()..addListener(_onScroll);

    final notifier = ref.read(topAuthorsControllerProvider.notifier);
    final lastQuery = notifier.lastQuery;

    if (lastQuery.isNotEmpty) {
      _currentTitle = lastQuery;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.fetchTopAuthors(lastQuery);
      });
    } else {
      _currentTitle = _globalTitle;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.fetchTopAuthors('');
      });
    }
  }

  @override
  void dispose() {
    _focusAnimController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isPaging) return;

    final position = _scrollController.position;
    if (!position.hasContentDimensions) return;
    if (position.maxScrollExtent <= 0) return;
    if (position.pixels < position.maxScrollExtent - 200) return;

    _isPaging = true;
    ref.read(topAuthorsControllerProvider.notifier).loadMore().whenComplete(() {
      _isPaging = false;
    });
  }

  void _onFocusChanged(bool hasFocus) {
    _isSearchBarFocused = hasFocus;
    if (hasFocus) {
      _focusAnimController.forward();
    } else {
      _focusAnimController.reverse();
    }
  }

  void _handleSearch(String keyword) {
    final query = keyword.trim();
    final isGlobal = query.isEmpty;

    setState(() {
      _currentTitle = isGlobal ? _globalTitle : query;
      _isSearchBarFocused = false;
    });

    _focusAnimController.reverse();
    FocusManager.instance.primaryFocus?.unfocus();

    ref
        .read(topAuthorsControllerProvider.notifier)
        .fetchTopAuthors(isGlobal ? '' : query);
  }

  void _openAuthorDetail(String authorId) {
    final keyword = ref
        .read(topAuthorsControllerProvider.notifier)
        .currentKeyword;
    final encodedKeyword = Uri.encodeComponent(keyword);
    context.push('${AppRoutes.topAuthors}/$authorId?topic=$encodedKeyword');
  }

  @override
  Widget build(BuildContext context) {
    final viewState = ref.watch(topAuthorsControllerProvider);
    final topPadding = MediaQuery.paddingOf(context).top;
    final isGlobalView = ref
        .read(topAuthorsControllerProvider.notifier)
        .isGlobalView;

    final isGlobal = _currentTitle == _globalTitle;
    final initialSearchQuery = isGlobal ? '' : _currentTitle;

    return TabScreenScaffold(
      body: Stack(
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
                      delegate: UniversalHeaderDelegate(
                        showBackButton: false,
                        topPadding: topPadding,
                        title: 'Top Authors & Researchers',
                        subtitle: _currentTitle,
                        searchBarInitialValue: initialSearchQuery,
                        searchBarHintText: 'Search for a research topic...',
                        focusProgress: _focusAnimController.value,
                        onFocusChanged: _onFocusChanged,
                        onSubmitted: _handleSearch,
                        onTopicSelected: (topic) {
                          _handleSearch(topic.displayName);
                        },
                      ),
                    );
                  },
                ),

                ...viewState.when(
                  loading: () => [
                    SliverToBoxAdapter(
                      child: TopAuthorsSkeleton(
                        key: const ValueKey('top_authors_loading'),
                        showHeatmap: isGlobal,
                      ),
                    ),
                  ],
                  error: (error, _) => [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: TopAuthorsErrorState(
                        message: error.toString(),
                        onRetry: () =>
                            _handleSearch(isGlobal ? '' : _currentTitle),
                      ),
                    ),
                  ],
                  data: (data) {
                    final paginated = data.authors;
                    final authors = paginated.items;

                    if (authors.isEmpty) {
                      return [
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: TopAuthorsEmptyState(
                            message:
                                'Không tìm thấy tác giả nào cho chủ đề này.',
                          ),
                        ),
                      ];
                    }

                    return [
                      // Phần thông tin tổng quan nằm trong Box Adapter
                      SliverToBoxAdapter(
                        key: const ValueKey('top_authors_data_header'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            data.isLoadingInsights
                                ? const GlobalAuthorInsightsSkeleton()
                                : data.globalInsights != null
                                ? GlobalAuthorInsightsRow(
                                    insights: data.globalInsights!,
                                  )
                                : const SizedBox.shrink(),
                            if (isGlobalView)
                              data.isLoadingMatrix
                                  ? const AuthorTopicHeatmapSkeleton()
                                  : data.topicMatrix != null
                                  ? AuthorTopicHeatmap(
                                      matrix: data.topicMatrix!,
                                    )
                                  : const SizedBox.shrink(),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                              child: Text(
                                isGlobal ? 'Global Leaderboard' : 'Leaderboard',
                                style: AppTextStyles.h3.copyWith(
                                  fontSize: 16,
                                  color: AppColors.brandBlue900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.only(top: 12),
                        sliver: SliverList.builder(
                          itemCount: authors.length,
                          itemBuilder: (context, index) {
                            final author = authors[index];
                            return AuthorRankTile(
                              rank: index + 1,
                              author: author,
                              onTap: () => _openAuthorDetail(author.id),
                            );
                          },
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: PaginationFooter(
                          isLoading: paginated.isLoadingMore,
                          hasMore: paginated.hasMore,
                        ),
                      ),
                      const SliverToBoxAdapter(child: TabBarContentPadding()),
                    ];
                  },
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
    );
  }
}
