import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/presentation/screens/home/widgets/home_stat_card.dart';
import 'package:synapse/presentation/screens/publication_search/widgets/publication_card_skeleton.dart';

/// Loading placeholder shaped like [HomeTopicOverview].
class HomeTopicOverviewSkeleton extends StatelessWidget {
  const HomeTopicOverviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bone(width: 220, height: 13, radius: 4),
                  const SizedBox(height: 16),
                  const _ChartBone(),
                  const SizedBox(height: 12),
                  const _StatRowBone(),
                  const SizedBox(height: 12),
                  const _StatRowBone(),
                  const SizedBox(height: 12),
                  const _FeaturedBone(tall: true),
                  const SizedBox(height: 10),
                  const _FeaturedBone(tall: false),
                  const SizedBox(height: 28),
                  const _InfluentialBone(),
                  const SizedBox(height: 28),
                  _Bone(width: 140, height: 14, radius: 4),
                  const SizedBox(height: 8),
                  _Bone(width: 180, height: 12, radius: 4),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const PublicationCardSkeleton(),
            const PublicationCardSkeleton(),
            const PublicationCardSkeleton(),
          ],
        ),
      ),
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
    this.radius = 12,
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

class _ChartBone extends StatelessWidget {
  const _ChartBone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Bone(width: 130, height: 14, radius: 4),
              const SizedBox(width: 10),
              const _Bone(width: 72, height: 12, radius: 4),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CustomPaint(
                painter: const _SparklineBonePainter(),
                child: const SizedBox(width: double.infinity, height: 160),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRowBone extends StatelessWidget {
  const _StatRowBone();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _StatCardBone()),
        SizedBox(width: 12),
        Expanded(child: _StatCardBone()),
      ],
    );
  }
}

class _StatCardBone extends StatelessWidget {
  const _StatCardBone();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: HomeStatCard.minCardHeight,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.5)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Bone(width: 16, height: 16, radius: 4),
                SizedBox(width: 8),
                Expanded(child: _Bone(height: 11, radius: 4)),
              ],
            ),
            Spacer(),
            _Bone(width: 72, height: 20, radius: 4),
          ],
        ),
      ),
    );
  }
}

class _FeaturedBone extends StatelessWidget {
  final bool tall;

  const _FeaturedBone({required this.tall});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Bone(width: 38, height: 38, radius: 19),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Bone(width: 120, height: 11, radius: 4),
                const SizedBox(height: 8),
                const _Bone(height: 16, radius: 4),
                if (tall) ...[
                  const SizedBox(height: 6),
                  const _Bone(width: 180, height: 16, radius: 4),
                ],
                const SizedBox(height: 8),
                const _Bone(width: 100, height: 11, radius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfluentialBone extends StatelessWidget {
  const _InfluentialBone();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.brandGold.withValues(alpha: 0.35),
          width: 1.2,
        ),
        color: AppColors.brandGold.withValues(alpha: 0.04),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Bone(width: 120, height: 22, radius: 20),
              Spacer(),
              _Bone(width: 80, height: 12, radius: 4),
            ],
          ),
          SizedBox(height: 16),
          _Bone(width: 140, height: 12, radius: 4),
          SizedBox(height: 10),
          _Bone(height: 18, radius: 4),
          SizedBox(height: 6),
          _Bone(width: 200, height: 18, radius: 4),
          SizedBox(height: 14),
          _Bone(width: 160, height: 12, radius: 4),
          SizedBox(height: 8),
          _Bone(width: 220, height: 12, radius: 4),
        ],
      ),
    );
  }
}

class _SparklineBonePainter extends CustomPainter {
  const _SparklineBonePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[
      Offset(0, size.height * 0.72),
      Offset(size.width * 0.16, size.height * 0.58),
      Offset(size.width * 0.32, size.height * 0.64),
      Offset(size.width * 0.48, size.height * 0.40),
      Offset(size.width * 0.64, size.height * 0.48),
      Offset(size.width * 0.80, size.height * 0.28),
      Offset(size.width, size.height * 0.36),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklineBonePainter oldDelegate) => false;
}
