import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/presentation/controllers/search_controller.dart';

import 'widgets/publication_card.dart';
import 'widgets/publication_card_skeleton.dart';
import 'widgets/search_autocomplete_bar.dart';

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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.brandBlue900, AppColors.brandBlue700],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRect(
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: SizedBox(
                        height: _isFocused ? 0 : 56,
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            'SYNAPSE',
                            style: AppTextStyles.h2.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: SearchAutocompleteBar(
                      onFocusChanged: (hasFocus) {
                        setState(() {
                          _isFocused = hasFocus;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
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
                        if (publications.isEmpty) {
                          return const Center(
                            key: ValueKey('empty_state'),
                            child: Text('Không có dữ liệu.'),
                          );
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
