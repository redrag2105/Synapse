import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/domain/entities/keyword_entity.dart';

class KeywordChip extends StatelessWidget {
  final KeywordEntity keyword;
  final bool showCount;
  final VoidCallback? onTap;

  const KeywordChip({
    super.key,
    required this.keyword,
    this.showCount = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.borderGray),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              keyword.displayName,
              style: AppTextStyles.button.copyWith(
                color: AppColors.brandBlue900,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (showCount && keyword.worksCount > 0) ...[
              const SizedBox(width: 8),
              Text(
                _formatCount(keyword.worksCount),
                style: AppTextStyles.metadata.copyWith(
                  fontSize: 11,
                  color: AppColors.brandBlue500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class KeywordChipSkeleton extends StatelessWidget {
  final double width;

  const KeywordChipSkeleton({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.white,
      child: Container(
        width: width,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
