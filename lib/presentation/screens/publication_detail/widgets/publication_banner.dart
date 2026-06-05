import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/app/utils/url_helper.dart';
import 'package:synapse/domain/entities/publication_entity.dart';

class PublicationBanner extends StatelessWidget {
  final PublicationEntity publication;

  const PublicationBanner({super.key, required this.publication});

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
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.brandBlue900, AppColors.brandBlue700],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            publication.title,
            style: AppTextStyles.h1.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              Text(
                typeFormatted,
                style: AppTextStyles.metadata.copyWith(color: Colors.white70),
              ),
              const Text('|', style: TextStyle(color: Colors.white38)),
              if (publication.isOa) ...[
                Text(
                  'Open access',
                  style: AppTextStyles.metadata.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white54,
                  ),
                ),
                const Text('|', style: TextStyle(color: Colors.white38)),
              ],
              Text(
                'Published: $displayDate',
                style: AppTextStyles.metadata.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppFormatters.buildVolumeInfo(
              volume: publication.volume,
              issue: publication.issue,
              firstPage: publication.firstPage,
              year: publication.publicationYear,
            ),
            style: AppTextStyles.metadata.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          if (publication.isOa) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF17BD6A),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.metadata.copyWith(
                        color: Colors.white,
                      ),
                      children: [
                        const TextSpan(text: 'You have full access to this '),
                        TextSpan(
                          text: 'open access',
                          style: AppTextStyles.metadata.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: ' article'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => UrlHelper.launch(publication.doi),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.brandBlue900,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(CupertinoIcons.link, size: 20),
                  label: Text(
                    'View Full Article',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.brandBlue900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => UrlHelper.launch(
                    publication.fullTextUrl ?? publication.doi,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(CupertinoIcons.arrow_down_doc, size: 20),
                  label: Text(
                    'Download PDF',
                    style: AppTextStyles.button.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
