import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';

class TrendEmptyState extends StatelessWidget {
  const TrendEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.graph_circle,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No trend available',
              style: AppTextStyles.h2.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Not enough publication data to generate a trend.',
              style: AppTextStyles.metadata,
            ),
          ],
        ),
      ),
    );
  }
}
