import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';

class SearchEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isInitialState;

  const SearchEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isInitialState = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isInitialState)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.brandBlue900.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: AppColors.brandBlue900),
            )
          else
            Icon(icon, size: 64, color: AppColors.borderGray),

          const SizedBox(height: 24),

          Text(
            title,
            style: AppTextStyles.h2.copyWith(
              fontFamily: isInitialState ? 'Merriweather' : null,
              color: isInitialState
                  ? AppColors.brandBlue900
                  : AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              subtitle,
              style: AppTextStyles.metadata.copyWith(fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
