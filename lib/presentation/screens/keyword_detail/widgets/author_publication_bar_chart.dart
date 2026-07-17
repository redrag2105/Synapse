import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/domain/entities/author_entity.dart';

/// Horizontal bar ranking of authors by publication count for a keyword.
class AuthorPublicationBarChart extends StatelessWidget {
  final List<AuthorEntity> authors;
  final void Function(AuthorEntity author)? onAuthorTap;
  final int maxBars;

  const AuthorPublicationBarChart({
    super.key,
    required this.authors,
    this.onAuthorTap,
    this.maxBars = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (authors.isEmpty) return const SizedBox.shrink();

    final top = authors.take(maxBars).toList();
    final maxCount = top
        .map((a) => a.worksCount)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Author ranking by publications',
            style: AppTextStyles.h3.copyWith(
              fontSize: 14,
              color: AppColors.brandBlue900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ranked by works associated with this keyword.',
            style: AppTextStyles.metadata.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 16),
          ...top.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final author = entry.value;
            return _AuthorBarRow(
              rank: rank,
              author: author,
              maxCount: maxCount,
              onTap: onAuthorTap != null ? () => onAuthorTap!(author) : null,
            );
          }),
        ],
      ),
    );
  }
}

class _AuthorBarRow extends StatelessWidget {
  final int rank;
  final AuthorEntity author;
  final int maxCount;
  final VoidCallback? onTap;

  const _AuthorBarRow({
    required this.rank,
    required this.author,
    required this.maxCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = maxCount > 0 ? author.worksCount / maxCount : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    '$rank',
                    style: AppTextStyles.metadata.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    author.displayName,
                    style: AppTextStyles.button.copyWith(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppFormatters.formatNumber(author.worksCount),
                  style: AppTextStyles.metadata.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: AppColors.surfaceGray,
                color: AppColors.brandBlue700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
