import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/presentation/controllers/search_controller.dart';
import 'package:synapse/presentation/widgets/search_bar.dart';

class SearchHeader extends ConsumerWidget {
  final bool isFocused;
  final ValueChanged<bool> onFocusChanged;

  const SearchHeader({
    super.key,
    required this.isFocused,
    required this.onFocusChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedContainer(
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
                  height: isFocused ? 0 : 56,
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
              child: UniversalSearchBar(
                initialValue: ref
                    .read(searchControllerProvider.notifier)
                    .lastQuery,
                hintText: 'Search for topics...',
                onFocusChanged: onFocusChanged,
                onSubmitted: (query) {
                  ref.read(searchControllerProvider.notifier).search(query);
                },
                onTopicSelected: (topic) {
                  ref
                      .read(searchControllerProvider.notifier)
                      .searchByTopicId(topic);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
