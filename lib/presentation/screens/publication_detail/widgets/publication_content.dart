import 'package:flutter/cupertino.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/domain/entities/publication_entity.dart';

class PublicationContent extends StatelessWidget {
  final PublicationEntity publication;

  const PublicationContent({super.key, required this.publication});

  @override
  Widget build(BuildContext context) {
    final abstractText = AppFormatters.decodeAbstract(
      publication.abstractInvertedIndex,
    );

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: publication.authors.asMap().entries.map((entry) {
              int idx = entry.key;
              var author = entry.value;
              bool isLast = idx == publication.authors.length - 1;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    author.displayName,
                    style: AppTextStyles.metadata.copyWith(
                      color: AppColors.brandBlue900,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.brandBlue900.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Text(
                      ',  ',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: AppColors.borderGray, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.doc_text,
                  size: 22,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${publication.citationCount}',
                  style: AppTextStyles.h3.copyWith(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text('Citations', style: AppTextStyles.metadata),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Abstract', style: AppTextStyles.h2),
          const SizedBox(height: 16),
          Text(
            abstractText,
            style: AppTextStyles.bodyText,
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 40),
          if (publication.concepts.isNotEmpty) ...[
            Text('Concepts', style: AppTextStyles.h2),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: publication.concepts.take(10).map((concept) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGray,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    concept,
                    style: AppTextStyles.metadata.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }
}
