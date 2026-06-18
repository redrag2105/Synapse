import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/domain/entities/author_entity.dart';

class AuthorRankTile extends StatelessWidget {
  final int rank;
  final AuthorEntity author;
  final VoidCallback onTap;

  const AuthorRankTile({
    super.key,
    required this.rank,
    required this.author,
    required this.onTap,
  });

  Color? _rankColor() {
    return switch (rank) {
      1 => const Color(0xFFD4AF37),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => null,
    };
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _rankColor();

    return Material(
      color: AppColors.background,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.borderGray, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '$rank',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: rankColor ?? AppColors.textLight,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: rankColor != null
                    ? rankColor.withValues(alpha: 0.2)
                    : AppColors.brandBlue900.withValues(alpha: 0.08),
                child: Text(
                  _initials(author.displayName),
                  style: AppTextStyles.metadata.copyWith(
                    fontWeight: FontWeight.bold,
                    color: rankColor ?? AppColors.brandBlue900,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  author.displayName,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppFormatters.formatNumber(author.worksCount),
                    style: AppTextStyles.metadata.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandBlue700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    CupertinoIcons.doc_text,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
