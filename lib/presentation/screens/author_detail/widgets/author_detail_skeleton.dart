import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/presentation/screens/author_detail/widgets/author_detail_header_delegate.dart';
import 'package:synapse/presentation/screens/journal_detail/widgets/journal_detail_stats_card.dart';
import 'package:synapse/presentation/screens/journal_detail/widgets/journal_detail_stats_card_skeleton.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/publication_card_skeleton.dart';

class AuthorDetailSkeleton extends StatelessWidget {
  const AuthorDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final heroHeight =
        topPadding +
        AuthorDetailHeaderDelegate.backRowHeight +
        AuthorDetailHeaderDelegate.expandedBodyHeight;
    final statsTop = heroHeight - AuthorDetailHeaderDelegate.statsOverlap;
    final headerHeight =
        heroHeight -
        AuthorDetailHeaderDelegate.statsOverlap +
        JournalDetailStatsCard.totalHeight;

    return ColoredBox(
      color: AppColors.background,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: headerHeight,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: heroHeight,
                    child: const _ProfileHeaderSkeleton(),
                  ),
                  Positioned(
                    top: statsTop,
                    left: 0,
                    right: 0,
                    child: const JournalDetailStatsCardSkeleton(),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: _WorksSectionSkeleton()),
        ],
      ),
    );
  }
}

class _ProfileHeaderSkeleton extends StatelessWidget {
  const _ProfileHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandBlue900, AppColors.brandBlue700],
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: 0.1),
        highlightColor: Colors.white.withValues(alpha: 0.25),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, topPadding + 56, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 120, height: 10, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(width: 80, height: 10, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 180,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 140,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 40,
                height: 3,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorksSectionSkeleton extends StatelessWidget {
  const _WorksSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.white,
            child: Container(
              width: 200,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const PublicationCardSkeleton(),
        const PublicationCardSkeleton(),
        const PublicationCardSkeleton(),
      ],
    );
  }
}
