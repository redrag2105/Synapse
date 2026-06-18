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
    });

    _focusAnimController.reverse();
    FocusManager.instance.primaryFocus?.unfocus();

    ref.read(topAuthorsControllerProvider.notifier).fetchTopAuthors(
          isGlobal ? '' : query,
        );
  }

  void _openAuthorDetail(String authorId) {
    final keyword =
        ref.read(topAuthorsControllerProvider.notifier).currentKeyword;
    final encodedKeyword = Uri.encodeComponent(keyword);
    context.push('${AppRoutes.topAuthors}/$authorId?topic=$encodedKeyword');
  }

  @override
  Widget build(BuildContext context) {
    final viewState = ref.watch(topAuthorsControllerProvider);
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final isGlobalView =
        ref.read(topAuthorsControllerProvider.notifier).isGlobalView;

    final isGlobal = _currentTitle == _globalTitle;
    final initialSearchQuery = isGlobal ? '' : _currentTitle;

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        bottom: true,
        child: CustomScrollView(
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
                child: viewState.when(
                  loading: () => TopAuthorsSkeleton(
                    key: const ValueKey('top_authors_loading'),
                    showHeatmap: isGlobal,
                  ),
                  error: (error, _) => SizedBox(
                    key: const ValueKey('top_authors_error'),
                    height: 400,
                    child: TopAuthorsErrorState(
                      message: error.toString(),
                      onRetry: () => _handleSearch(
                        isGlobal ? '' : _currentTitle,
                      ),
                    ),
                  ),
                  data: (data) {
                    final paginated = data.authors;
                    final authors = paginated.items;

                    if (authors.isEmpty) {
                      return const SizedBox(
                        key: ValueKey('top_authors_empty'),
                        height: 400,
                        child: TopAuthorsEmptyState(
                          message:
                              'Không tìm thấy tác giả nào cho chủ đề này.',
                        ),
                      );
                    }

                    return Column(
                      key: const ValueKey('top_authors_data'),
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
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            isGlobal ? 'Global Leaderboard' : 'Leaderboard',
                            style: AppTextStyles.h3.copyWith(
                              fontSize: 16,
                              color: AppColors.brandBlue900,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                        PaginationFooter(
                          isLoading: paginated.isLoadingMore,
                          hasMore: paginated.hasMore,
                        ),
                        SizedBox(height: bottomPadding),
                      ],
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
