import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/presentation/controllers/search_controller.dart';
import 'package:synapse/presentation/screens/search/widgets/publication_card.dart';
import 'package:synapse/presentation/screens/search/widgets/publication_card_skeleton.dart';
import 'package:synapse/presentation/screens/search/widgets/search_empty_state.dart';
import 'package:synapse/presentation/screens/search/widgets/search_header.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SearchHeader(
            isFocused: _isFocused,
            onFocusChanged: (hasFocus) {
              setState(() => _isFocused = hasFocus);
            },
          ),

          // BODY CONTENT
          Expanded(
            child: SafeArea(
              top: false,
              bottom: true,
              child: Stack(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: searchState.when(
                      loading: () => ListView.builder(
                        key: const ValueKey('loading_skeleton'),
                        padding: const EdgeInsets.only(top: 16),
                        itemCount: 5,
                        itemBuilder: (context, index) =>
                            const PublicationCardSkeleton(),
                      ),
                      error: (error, stack) => Center(
                        key: const ValueKey('error_state'),
                        child: Text('Lỗi: ${error.toString()}'),
                      ),
                      data: (publications) {
                        final lastQuery = ref
                            .read(searchControllerProvider.notifier)
                            .lastQuery;

                        if (publications.isEmpty) {
                          if (lastQuery.isEmpty) {
                            return const SearchEmptyState(
                              key: ValueKey('initial_state'),
                              isInitialState: true,
                              icon: CupertinoIcons.book,
                              title: 'Discover the Unknown',
                              subtitle:
                                  'Search across millions of scholarly works, authors, and topics to start your research.',
                            );
                          } else {
                            return SearchEmptyState(
                              key: const ValueKey('empty_state'),
                              isInitialState: false,
                              icon: CupertinoIcons.search,
                              title: 'No results found',
                              subtitle:
                                  'We couldn\'t find anything matching "$lastQuery".\nTry checking your spelling or use broader terms.',
                            );
                          }
                        }

                        return ListView.builder(
                          key: const ValueKey('real_data_list'),
                          padding: const EdgeInsets.only(top: 16),
                          itemCount: publications.length,
                          itemBuilder: (context, index) {
                            return PublicationCard(
                              publication: publications[index],
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // SEARCH OVERLAY
                  IgnorePointer(
                    ignoring: !_isFocused,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      opacity: _isFocused ? 1.0 : 0.0,
                      child: GestureDetector(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Container(
                          color: Colors.black.withValues(alpha: .5),
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
