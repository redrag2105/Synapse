import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TopAuthorsSkeleton extends StatelessWidget {
  final bool showHeatmap;

  const TopAuthorsSkeleton({
    super.key,
    this.showHeatmap = true,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        bottom: bottomPadding + 40,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _MetricCardsSkeleton(),
            if (showHeatmap) ...[
              const SizedBox(height: 16),
              _buildSkeletonBox(height: 320),
            ],
            const SizedBox(height: 24),
            _buildSkeletonBox(height: 20, width: 160, borderRadius: 6),
            const SizedBox(height: 8),
            const _AuthorListSkeleton(itemCount: 6),
          ],
        ),
      ),
    );
  }
}

class GlobalAuthorInsightsSkeleton extends StatelessWidget {
  const GlobalAuthorInsightsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.white,
        child: const _MetricCardsSkeleton(),
      ),
    );
  }
}

class AuthorTopicHeatmapSkeleton extends StatelessWidget {
  const AuthorTopicHeatmapSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.white,
        child: _buildSkeletonBox(height: 320),
      ),
    );
  }
}

class _MetricCardsSkeleton extends StatelessWidget {
  const _MetricCardsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSkeletonBox(height: 105)),
            const SizedBox(width: 12),
            Expanded(child: _buildSkeletonBox(height: 105)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSkeletonBox(height: 105)),
            const SizedBox(width: 12),
            Expanded(child: _buildSkeletonBox(height: 105)),
          ],
        ),
      ],
    );
  }
}

class _AuthorListSkeleton extends StatelessWidget {
  final int itemCount;

  const _AuthorListSkeleton({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  _buildSkeletonBox(width: 24, height: 20, borderRadius: 4),
                  const SizedBox(width: 12),
                  _buildSkeletonBox(width: 44, height: 44, borderRadius: 22),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: _AuthorNameSkeleton(),
                  ),
                  const SizedBox(width: 12),
                  _buildSkeletonBox(width: 48, height: 16, borderRadius: 4),
                ],
              ),
            ),
            if (index < itemCount - 1)
              _buildSkeletonBox(height: 1, borderRadius: 0),
          ],
        );
      }),
    );
  }
}

class _AuthorNameSkeleton extends StatelessWidget {
  const _AuthorNameSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSkeletonBox(height: 14, borderRadius: 4),
        const SizedBox(height: 6),
        _buildSkeletonBox(height: 14, width: 120, borderRadius: 4),
      ],
    );
  }
}

Widget _buildSkeletonBox({
  required double height,
  double? width,
  double borderRadius = 16,
}) {
  return Container(
    height: height,
    width: width ?? double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
    ),
  );
}
