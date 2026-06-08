import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/routes/app_routes.dart';
import 'package:synapse/presentation/controllers/publication_search_controller.dart';
import 'package:synapse/presentation/controllers/publication_trend_controller.dart';
import 'package:synapse/presentation/screens/search/widgets/publication_card.dart';
import 'package:synapse/presentation/screens/search/widgets/publication_card_skeleton.dart';
import 'package:synapse/presentation/screens/search/widgets/search_empty_state.dart';
import 'package:synapse/presentation/screens/search/widgets/smart_trend_button.dart';
import 'package:synapse/presentation/widgets/universal_header_delegate.dart';

class PublicationSearchScreen extends ConsumerStatefulWidget {
  const PublicationSearchScreen({super.key});

  @override
  ConsumerState<PublicationSearchScreen> createState() =>
      _PublicationSearchScreenState();
}

class _PublicationSearchScreenState
    extends ConsumerState<PublicationSearchScreen>
    with SingleTickerProviderStateMixin {
  bool _isFocused = false;
  late final AnimationController _focusAnimController;

  @override
  void initState() {
    super.initState();
    _focusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _focusAnimController.dispose();
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
    final searchState = ref.watch(publicationSearchControllerProvider);
    final topPadding = MediaQuery.paddingOf(context).top;
    final lastQuery = ref
        .watch(publicationSearchControllerProvider.notifier)
        .lastQuery;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
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

                        return ListView.builder(
                          key: const ValueKey('data_list'),
                          padding: const EdgeInsets.only(top: 16, bottom: 40),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: publications.length,
                          itemBuilder: (context, index) =>
                              PublicationCard(publication: publications[index]),
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
              // Tự động thụt xuống ẩn đi nếu đang gõ phím, đang tải hoặc keyword rỗng
              bottom: (_isFocused || lastQuery.isEmpty || searchState.isLoading)
                  ? -100
                  : bottomPadding + 24,
              left: 0,
              right: 0,
              child: Center(
                child: SmartTrendButton(
                  keyword: lastQuery,
                  onTap: () {
                    ref
                        .read(publicationTrendControllerProvider.notifier)
                        .setExternalNavigation(lastQuery, lastQuery);
                    context.push(AppRoutes.trend);
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
