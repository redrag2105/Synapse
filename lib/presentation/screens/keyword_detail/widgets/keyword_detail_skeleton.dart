import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/publication_card_skeleton.dart';

/// Shimmer placeholders shaped like Keyword Detail sections.
class KeywordDetailTrendSkeleton extends StatelessWidget {
  const KeywordDetailTrendSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                _Bone(width: 160, height: 14),
                SizedBox(width: 10),
                _Bone(width: 72, height: 12),
              ],
            ),
            const SizedBox(height: 24),
            const _Bone(height: 200, radius: 12),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                5,
                (_) => const _Bone(width: 36, height: 10, radius: 4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KeywordDetailAuthorsSkeleton extends StatelessWidget {
  const KeywordDetailAuthorsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderGray.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Bone(width: 180, height: 14),
                const SizedBox(height: 6),
                const _Bone(width: 220, height: 11),
                const SizedBox(height: 18),
                for (var i = 0; i < 5; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  const _BarRowBone(),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderGray.withValues(alpha: 0.5),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: AppColors.borderGray),
                  const _AuthorTileBone(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class KeywordDetailJournalsSkeleton extends StatelessWidget {
  const KeywordDetailJournalsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderGray.withValues(alpha: 0.5),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < 5; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.borderGray),
              const _JournalTileBone(),
            ],
          ],
        ),
      ),
    );
  }
}

class KeywordDetailPublicationsSkeleton extends StatelessWidget {
  const KeywordDetailPublicationsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        PublicationCardSkeleton(),
        PublicationCardSkeleton(),
        PublicationCardSkeleton(),
      ],
    );
  }
}

class _Bone extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _Bone({
    this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _BarRowBone extends StatelessWidget {
  const _BarRowBone();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Bone(width: 18, height: 12, radius: 4),
            SizedBox(width: 8),
            Expanded(child: _Bone(height: 12, radius: 4)),
            SizedBox(width: 8),
            _Bone(width: 36, height: 12, radius: 4),
          ],
        ),
        SizedBox(height: 6),
        _Bone(height: 8, radius: 4),
      ],
    );
  }
}

class _AuthorTileBone extends StatelessWidget {
  const _AuthorTileBone();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _Bone(width: 24, height: 16, radius: 4),
          SizedBox(width: 8),
          _Bone(width: 44, height: 44, radius: 22),
          SizedBox(width: 14),
          Expanded(child: _Bone(height: 16, radius: 4)),
          SizedBox(width: 12),
          _Bone(width: 40, height: 14, radius: 4),
        ],
      ),
    );
  }
}

class _JournalTileBone extends StatelessWidget {
  const _JournalTileBone();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _Bone(width: 22, height: 16, radius: 4),
          SizedBox(width: 8),
          Expanded(child: _Bone(height: 15, radius: 4)),
          SizedBox(width: 12),
          _Bone(width: 48, height: 14, radius: 4),
        ],
      ),
    );
  }
}
