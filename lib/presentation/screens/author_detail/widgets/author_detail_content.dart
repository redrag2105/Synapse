import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/domain/entities/author_entity.dart';
import 'package:synapse/domain/entities/publication_entity.dart';
import 'package:synapse/presentation/screens/search/widgets/publication_card.dart';
import 'package:synapse/presentation/widgets/pagination_footer.dart';

class AuthorProfileHeader extends StatelessWidget {
  final AuthorEntity profile;
  final String topicLabel;

  const AuthorProfileHeader({
    super.key,
    required this.profile,
    required this.topicLabel,
  });

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
    final institution = profile.lastKnownInstitutionName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.brandBlue900,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            child: Text(
              _initials(profile.displayName),
              style: AppTextStyles.h1.copyWith(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.displayName,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (institution != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.building_2_fill,
                  size: 14,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    institution,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.metadata.copyWith(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                label: 'H-INDEX',
                value: '${profile.hIndex}',
              ),
              Container(
                width: 0.5,
                height: 36,
                color: Colors.white24,
              ),
              _StatItem(
                label: 'CITATIONS',
                value: AppFormatters.formatNumber(profile.citedByCount),
              ),
              Container(
                width: 0.5,
                height: 36,
                color: Colors.white24,
              ),
              _StatItem(
                label: 'WORKS',
                value: AppFormatters.formatNumber(profile.worksCount),
              ),
            ],
          ),
          if (topicLabel.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Topic: $topicLabel',
                style: AppTextStyles.metadata.copyWith(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h2.copyWith(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.metadata.copyWith(
            color: Colors.white60,
            fontSize: 10,
            letterSpacing: 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class AuthorWorksSection extends StatelessWidget {
  final List<PublicationEntity> works;
  final bool isLoadingMore;
  final bool hasMore;

  const AuthorWorksSection({
    super.key,
    required this.works,
    required this.isLoadingMore,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    if (works.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'Không tìm thấy bài báo nào của tác giả này cho chủ đề đã chọn.',
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
            'PUBLICATIONS ON TOPIC (${works.length})',
            style: AppTextStyles.h3.copyWith(
              fontSize: 11,
              color: AppColors.textLight,
              letterSpacing: 1.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...works.map((pub) => PublicationCard(publication: pub)),
        PaginationFooter(isLoading: isLoadingMore, hasMore: hasMore),
      ],
    );
  }
}
