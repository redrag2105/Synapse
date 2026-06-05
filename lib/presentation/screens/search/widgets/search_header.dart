import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'search_autocomplete_bar.dart';

class SearchHeader extends StatelessWidget {
  final bool isFocused;
  final ValueChanged<bool> onFocusChanged;

  const SearchHeader({
    super.key,
    required this.isFocused,
    required this.onFocusChanged,
  });

  @override
  Widget build(BuildContext context) {
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
              child: SearchAutocompleteBar(onFocusChanged: onFocusChanged),
            ),
          ],
        ),
      ),
    );
  }
}
