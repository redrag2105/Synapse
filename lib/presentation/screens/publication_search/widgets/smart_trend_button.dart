import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';

class SmartTrendButton extends StatelessWidget {
  final String keyword;
  final VoidCallback onTap;
  final bool isExpanded;

  const SmartTrendButton({
    super.key,
    required this.keyword,
    required this.onTap,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.brandBlue900.withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandBlue900.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: onTap,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  padding: isExpanded
                      ? const EdgeInsets.fromLTRB(16, 8, 12, 8)
                      : const EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.all(isExpanded ? 8 : 0),
                        decoration: BoxDecoration(
                          color: isExpanded
                              ? AppColors.brandBlue900.withValues(alpha: 0.1)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutCubic,
                          tween: Tween<double>(
                            begin: isExpanded ? 21.0 : 32.0,
                            end: isExpanded ? 21.0 : 32.0,
                          ),
                          builder: (context, size, child) {
                            return Icon(
                              CupertinoIcons.chart_bar_alt_fill,
                              color: AppColors.brandBlue900,
                              size: size,
                            );
                          },
                        ),
                      ),

                      AnimatedSize(
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.centerRight,
                        child: isExpanded
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'RESEARCH TREND',
                                          style: AppTextStyles.metadata
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.2,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Analyze "$keyword"',
                                          style: AppTextStyles.button.copyWith(
                                            color: AppColors.brandBlue900,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(
                                    CupertinoIcons.arrow_right_circle_fill,
                                    color: AppColors.brandBlue900,
                                    size: 32,
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
