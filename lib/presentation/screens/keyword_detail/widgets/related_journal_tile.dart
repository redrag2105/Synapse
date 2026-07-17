import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/domain/entities/journal_entity.dart';

class RelatedJournalTile extends StatelessWidget {
  final int rank;
  final JournalEntity journal;
  final VoidCallback onTap;
  final bool isLast;

  const RelatedJournalTile({
    super.key,
    required this.rank,
    required this.journal,
    required this.onTap,
    this.isLast = false,
  });

  Color? _rankColor() {
    return switch (rank) {
      1 => const Color(0xFFD4AF37),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _rankColor();

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: isLast
                  ? BorderSide.none
                  : const BorderSide(color: AppColors.borderGray, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '$rank',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: rank > 3 ? 13 : 16,
                    fontWeight: FontWeight.bold,
                    color: rankColor ?? AppColors.textLight,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  journal.displayName,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 14,
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
                    AppFormatters.formatNumber(journal.worksCount),
                    style: AppTextStyles.metadata.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandBlue700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    CupertinoIcons.doc_text,
                    size: 15,
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
