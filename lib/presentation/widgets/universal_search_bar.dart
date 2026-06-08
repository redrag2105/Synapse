import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/domain/entities/topic_entity.dart';

class UniversalSearchBar extends ConsumerStatefulWidget {
  final String initialValue;
  final String hintText;
  final bool enableAutocomplete;
  final bool restoreOnEmptySubmit;
  final ValueChanged<bool>? onFocusChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<TopicEntity>? onTopicSelected;
  final VoidCallback? onCleared;

  const UniversalSearchBar({
    super.key,
    this.initialValue = '',
    this.hintText = 'Search...',
    this.enableAutocomplete = true,
    this.restoreOnEmptySubmit = true,
    this.onFocusChanged,
    this.onSubmitted,
    this.onTopicSelected,
    this.onCleared,
  });

  @override
  ConsumerState<UniversalSearchBar> createState() => _UniversalSearchBarState();
}

class _UniversalSearchBarState extends ConsumerState<UniversalSearchBar> {
  bool _isFocused = false;
  bool _isLoadingHints = false;
  bool _isSubmittingEmpty = false;

  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<TopicEntity>(
      initialValue: TextEditingValue(text: widget.initialValue),

      optionsBuilder: (TextEditingValue textValue) async {
        if (!widget.enableAutocomplete ||
            textValue.text.trim().isEmpty ||
            !_isFocused) {
          return const Iterable<TopicEntity>.empty();
        }

        _debounceTimer?.cancel();

        final completer = Completer<Iterable<TopicEntity>>();

        _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
          if (mounted) setState(() => _isLoadingHints = true);

          final useCase = ref.read(getTopicHintsUseCaseProvider);
          final result = await useCase(textValue.text);

          if (mounted) setState(() => _isLoadingHints = false);

          completer.complete(
            result.fold(
              (failure) => const Iterable<TopicEntity>.empty(),
              (topics) => topics,
            ),
          );
        });

        return completer.future;
      },

      displayStringForOption: (TopicEntity option) => option.displayName,

      onSelected: (TopicEntity selection) {
        FocusManager.instance.primaryFocus?.unfocus();
        widget.onTopicSelected?.call(selection);
      },

      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return Focus(
          onFocusChange: (hasFocus) {
            setState(() => _isFocused = hasFocus);
            widget.onFocusChanged?.call(hasFocus);
            if (!hasFocus) {
              if (controller.text.trim().isEmpty) {
                if (_isSubmittingEmpty) {
                  _isSubmittingEmpty = false;
                } else if (widget.initialValue.isNotEmpty) {
                  controller.text = widget.initialValue;
                }
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
                    widget.onCleared?.call();
                  },
                );
              }

              return TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.search,
                style: AppTextStyles.bodyText,
                onSubmitted: (searchText) {
                  final query = searchText.trim();

                  if (query.isEmpty) {
                    if (widget.restoreOnEmptySubmit) {
                      focusNode.unfocus();
                    } else {
                      _isSubmittingEmpty = true;
                      focusNode.unfocus();
                      widget.onSubmitted?.call('');
                    }
                  } else {
                    focusNode.unfocus();
                    widget.onSubmitted?.call(query);
                  }
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
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

            child: ExcludeFocus(
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

                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification notification) {
                        return true;
                      },
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,

                        primary: false,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.manual,
                        physics: const BouncingScrollPhysics(),

                        itemCount: options.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          color: AppColors.borderGray,
                        ),
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
            ),
          ),
        );
      },
    );
  }
}
