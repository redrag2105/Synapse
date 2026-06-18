import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/domain/entities/leading_journal_entity.dart';

/// Section D — full ranked list with medal styling for the top 3 ranks.
class JournalLeaderboard extends StatelessWidget {
  final List<LeadingJournalEntity> journals;

  const JournalLeaderboard({super.key, required this.journals});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: journals.length,
      separatorBuilder: (_, _) => const Divider(
        height: 1,
        color: AppColors.borderGray,
      ),
      itemBuilder: (context, index) {
        final journal = journals[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: _rankBackground(index + 1),
            child: Text(
              '${index + 1}',
              style: AppTextStyles.h3.copyWith(
                fontSize: 13,
                color: _rankForeground(index + 1),
              ),
            ),
          ),
          title: Text(
            journal.name,
            style: AppTextStyles.h3.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppFormatters.formatNumber(journal.articleCount),
                    style: AppTextStyles.metadata.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandBlue700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.article_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    journal.hIndex.toStringAsFixed(0),
                    style: AppTextStyles.metadata.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandBlue600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.trending_up,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color? _rankBackground(int rank) {
    return switch (rank) {
      1 => const Color(0xFFD4AF37).withValues(alpha: 0.2),
      2 => const Color(0xFFC0C0C0).withValues(alpha: 0.25),
      3 => const Color(0xFFCD7F32).withValues(alpha: 0.25),
      _ => AppColors.brandBlue900.withValues(alpha: 0.08),
    };
  }

  Color _rankForeground(int rank) {
    return switch (rank) {
      1 => const Color(0xFFD4AF37),
      2 => const Color(0xFF8A8A8A),
      3 => const Color(0xFFCD7F32),
      _ => AppColors.brandBlue900,
    };
  }
}
