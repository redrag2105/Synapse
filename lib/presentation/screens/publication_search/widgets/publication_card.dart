import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/domain/entities/publication_entity.dart';

class PublicationCard extends StatelessWidget {
  final PublicationEntity publication;
  final bool isLastItem;

  const PublicationCard({
    super.key,
    required this.publication,
    this.isLastItem = false,
  });

  @override
  Widget build(BuildContext context) {
    final String typeFormatted = AppFormatters.formatArticleType(
      publication.articleType,
    );
    final String displayDate = AppFormatters.formatDate(
      publication.publicationDate,
      publication.publicationYear,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: isLastItem
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.borderGray, width: 1),
              ),
      ),
      child: InkWell(
        onTap: () {
          final id = publication.id.split('/').last;
          context.push('/detail/$id');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(typeFormatted, style: AppTextStyles.metadata),
                  if (publication.isOa) ...[
                    const Text(
                      '|',
                      style: TextStyle(color: AppColors.borderGray),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Open access',
                          style: AppTextStyles.metadata.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              Text(
                publication.title,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.brandBlue900,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                publication.authors
                        .take(3)
                        .map((e) => e.displayName)
                        .join(', ') +
                    (publication.authors.length > 3 ? '...' : ''),
                style: AppTextStyles.metadata.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                '${publication.journalName} ($displayDate)',
                style: AppTextStyles.metadata,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(
                    CupertinoIcons.doc_text,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${publication.citationCount} Citations',
                    style: AppTextStyles.metadata.copyWith(
                      color: AppColors.textSecondary,
                    ),
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
