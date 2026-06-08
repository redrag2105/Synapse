import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';

class SmartTrendButton extends StatelessWidget {
  final String keyword;
  final VoidCallback onTap;

  const SmartTrendButton({
    super.key,
    required this.keyword,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.brandBlue900.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandBlue900.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.graph_circle,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Analyze Trend for "$keyword"',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      CupertinoIcons.arrow_right,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
