import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/domain/entities/topic_entity.dart';
import 'package:synapse/presentation/controllers/search_controller.dart';

class SearchAutocompleteBar extends ConsumerStatefulWidget {
  final ValueChanged<bool> onFocusChanged;

  const SearchAutocompleteBar({super.key, required this.onFocusChanged});

  @override
  ConsumerState<SearchAutocompleteBar> createState() =>
      _SearchAutocompleteBarState();
}

class _SearchAutocompleteBarState extends ConsumerState<SearchAutocompleteBar> {
  bool _isFocused = false;
  bool _isLoadingHints = false;

  @override
  Widget build(BuildContext context) {
    final initialQuery = ref.read(searchControllerProvider.notifier).lastQuery;

    return Autocomplete<TopicEntity>(
      initialValue: TextEditingValue(text: initialQuery),
      optionsBuilder: (TextEditingValue textValue) async {
        if (textValue.text.trim().isEmpty || !_isFocused) {
          return const Iterable<TopicEntity>.empty();
        }

        setState(() => _isLoadingHints = true);
        final useCase = ref.read(getTopicHintsUseCaseProvider);
        final result = await useCase(textValue.text);
        if (mounted) setState(() => _isLoadingHints = false);

        return result.fold(
          (failure) => const Iterable<TopicEntity>.empty(),
          (topics) => topics,
        );
      },
      displayStringForOption: (TopicEntity option) => option.displayName,
      onSelected: (TopicEntity selection) {
        ref.read(searchControllerProvider.notifier).searchByTopicId(selection);
        FocusManager.instance.primaryFocus?.unfocus();
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return Focus(
          onFocusChange: (hasFocus) {
            setState(() => _isFocused = hasFocus);
            widget.onFocusChanged(hasFocus);

            if (!hasFocus) {
              final lastQuery = ref
                  .read(searchControllerProvider.notifier)
                  .lastQuery;
              if (controller.text.trim().isEmpty && lastQuery.isNotEmpty) {
                controller.text = lastQuery;
              }
            }
          },
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              Widget? suffixIcon;
              if (_isLoadingHints) {
                suffixIcon = const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: CircularProgressIndicator(strokeWidth: 2.7),
                  ),
                );
              } else if (_isFocused && value.text.isNotEmpty) {
                suffixIcon = IconButton(
                  icon: const Icon(
                    CupertinoIcons.clear_circled_solid,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    controller.clear();
                  },
                );
              }

              return TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.search,
                style: AppTextStyles.bodyText,
                onSubmitted: (searchText) {
                  focusNode.unfocus();
                  final query = searchText.trim();

                  if (query.isNotEmpty) {
                    ref.read(searchControllerProvider.notifier).search(query);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search for topics...',
                  hintStyle: const TextStyle(color: Colors.black45),
                  prefixIcon: const Icon(
                    CupertinoIcons.search,
                    color: AppColors.brandBlue900,
                  ),
                  suffixIcon: suffixIcon,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              );
            },
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
            child: Material(
              elevation: 8,
              shadowColor: Colors.black26,
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 450),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 32,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: AppColors.borderGray),
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: const Icon(
                          CupertinoIcons.search,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        title: Text(
                          option.displayName,
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.brandBlue900,
                          ),
                        ),
                        subtitle: Text(
                          option.description ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.metadata,
                        ),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
