import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/routes/app_routes.dart';
import 'package:synapse/presentation/controllers/publication_search_controller.dart';
import 'package:synapse/presentation/controllers/publication_trend_controller.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/publication_card.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/publication_card_skeleton.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/search_empty_state.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/smart_trend_button.dart';
import 'package:synapse/presentation/widgets/universal_header_delegate.dart';

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

  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<bool> _isButtonExpanded = ValueNotifier(true);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _focusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isButtonExpanded.value) _isButtonExpanded.value = false;
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isButtonExpanded.value) _isButtonExpanded.value = true;
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(publicationSearchControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _focusAnimController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _isButtonExpanded.dispose();
    super.dispose();
  }

  void _onFocusChanged(bool hasFocus) {
    _isFocused = hasFocus;
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
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final lastQuery = controller.lastQuery;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        bottom: true,
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
                        restoreOnEmptySubmit: true,
                        topPadding: topPadding,
                        title: 'Search Publications',
                        subtitle: lastQuery.isEmpty
                            ? 'Discover Scholarly Works'
                            : lastQuery,
                        searchBarInitialValue: lastQuery,
                        searchBarHintText: 'Search for topics...',
                        focusProgress: _focusAnimController.value,
                        onFocusChanged: _onFocusChanged,
                        onSubmitted: (query) {
                          ref
                              .read(
                                publicationSearchControllerProvider.notifier,
                              )
                              .search(query);
                        },
                        onTopicSelected: (topic) {
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

                SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
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
                    child: searchState.when(
                      loading: () => ListView.builder(
                        key: const ValueKey('loading_skeleton'),
                        padding: const EdgeInsets.only(top: 16, bottom: 40),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        itemBuilder: (context, index) =>
                            const PublicationCardSkeleton(),
                      ),

                      error: (error, stack) => ConstrainedBox(
                        key: const ValueKey('error_state'),
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.sizeOf(context).height * 0.5,
                        ),
                        child: Center(child: Text('Lỗi: ${error.toString()}')),
                      ),

                      data: (publications) {
                        if (publications.isEmpty) {
                          return ConstrainedBox(
                            key: const ValueKey('empty_state'),
                            constraints: BoxConstraints(
                              minHeight:
                                  MediaQuery.sizeOf(context).height * 0.6,
                            ),
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
                          );
                        }

                        final hasReachedMax = controller.hasReachedMax;
                        final itemCount =
                            publications.length + (hasReachedMax ? 0 : 1);

                        return ListView.builder(
                          key: const ValueKey('data_list'),
                          padding: const EdgeInsets.only(top: 16, bottom: 40),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                            if (index == publications.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3.6,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return TweenAnimationBuilder<double>(
                              key: ValueKey(publications[index].id),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutCubic,
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: Opacity(
                                    opacity: value.clamp(0.0, 1.0),
                                    child: child,
                                  ),
                                );
                              },
                              child: PublicationCard(
                                publication: publications[index],
                                isLastItem: index == publications.length - 1,
                              ),
                            );
                          },
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

            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              bottom: (_isFocused || lastQuery.isEmpty || searchState.isLoading)
                  ? -100
                  : bottomPadding,
              left: 16,
              right: 16,
              child: ValueListenableBuilder<bool>(
                valueListenable: _isButtonExpanded,
                builder: (context, isExpanded, child) {
                  return AnimatedAlign(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    alignment: isExpanded
                        ? Alignment.bottomCenter
                        : Alignment.bottomRight,
                    child: SmartTrendButton(
                      keyword: lastQuery,
                      isExpanded: isExpanded,
                      onTap: () {
                        ref
                            .read(publicationTrendControllerProvider.notifier)
                            .setExternalNavigation(lastQuery, lastQuery);
                        context.push(AppRoutes.trend);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
