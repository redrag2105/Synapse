import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/presentation/screens/search/widgets/publication_card_skeleton.dart';

class AuthorDetailSkeleton extends StatelessWidget {
  const AuthorDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.brandBlue900,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const SliverToBoxAdapter(
          child: _ProfileHeaderSkeleton(),
        ),
        const SliverToBoxAdapter(
          child: _WorksSectionSkeleton(),
        ),
      ],
    );
  }
}

class _ProfileHeaderSkeleton extends StatelessWidget {
  const _ProfileHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.brandBlue900,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: 0.1),
        highlightColor: Colors.white.withValues(alpha: 0.25),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 220,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 160,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _StatSkeleton(),
                _StatSkeleton(),
                _StatSkeleton(),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: 140,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 56,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
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
              height: 12,
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
        const PublicationCardSkeleton(),
      ],
    );
  }
}
