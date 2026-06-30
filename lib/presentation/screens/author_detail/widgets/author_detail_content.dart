import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/domain/entities/publication_entity.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/publication_card.dart';
import 'package:synapse/presentation/widgets/pagination_footer.dart';

class AuthorWorksSection extends StatelessWidget {
  final List<PublicationEntity> works;
  final int totalWorksCount;
  final String topicLabel;
  final bool isLoadingMore;
  final bool hasMore;

  const AuthorWorksSection({
    super.key,
    required this.works,
    required this.totalWorksCount,
    required this.topicLabel,
    required this.isLoadingMore,
    required this.hasMore,
  });

  String _sectionTitle() {
    final count = AppFormatters.formatNumber(totalWorksCount);
    if (topicLabel.isEmpty) {
      return 'Publications ($count)';
    }
    return 'Publications on "$topicLabel" ($count)';
  }

  @override
  Widget build(BuildContext context) {
    if (works.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No publications found for this author and topic.',
          textAlign: TextAlign.center,
          style: AppTextStyles.metadata.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(
            _sectionTitle(),
            style: AppTextStyles.h3.copyWith(
              color: AppColors.brandBlue900,
              fontSize: 15,
            ),
          ),
        ),
        ...works.map(
          (pub) => PublicationCard(
            key: ValueKey(pub.id),
            publication: pub,
          ),
        ),
        PaginationFooter(isLoading: isLoadingMore, hasMore: hasMore),
      ],
    );
  }
}
