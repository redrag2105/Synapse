import 'package:flutter/cupertino.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/presentation/screens/home/widgets/home_stat_card.dart';

/// Static preview of the research-topic dashboard shown before the user searches.
class HomeDashboardTeaser extends StatelessWidget {
  const HomeDashboardTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Research topic overview',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.brandBlue900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Search a topic above to explore publication trends, citations, '
            'top authors, journals, and influential works.',
            style: AppTextStyles.metadata.copyWith(
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          const _TeaserChartCard(),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: HomeStatCard(
                  icon: CupertinoIcons.doc_text,
                  label: 'Total publications',
                  value: '—',
                  isPlaceholder: true,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: HomeStatCard(
                  icon: CupertinoIcons.quote_bubble,
                  label: 'Avg. citations',
                  value: '—',
                  isPlaceholder: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: HomeStatCard(
                  icon: CupertinoIcons.calendar,
                  label: 'Most active year',
                  value: '—',
                  isPlaceholder: true,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: HomeStatCard(
                  icon: CupertinoIcons.person,
                  label: 'Top author',
                  value: '—',
                  isPlaceholder: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: HomeStatCard(
                  icon: CupertinoIcons.book,
                  label: 'Top journal',
                  value: '—',
                  isPlaceholder: true,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: HomeStatCard(
                  icon: CupertinoIcons.star,
                  label: 'Most influential',
                  value: '—',
                  isPlaceholder: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeaserChartCard extends StatelessWidget {
  const _TeaserChartCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Publication trend',
            style: AppTextStyles.metadata.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 72,
            child: CustomPaint(
              painter: _TeaserSparklinePainter(
                color: AppColors.brandBlue700.withValues(alpha: 0.35),
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chart appears after you search a topic',
            style: AppTextStyles.metadata.copyWith(
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeaserSparklinePainter extends CustomPainter {
  final Color color;

  _TeaserSparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.18, size.height * 0.55),
      Offset(size.width * 0.35, size.height * 0.62),
      Offset(size.width * 0.52, size.height * 0.38),
      Offset(size.width * 0.68, size.height * 0.45),
      Offset(size.width * 0.84, size.height * 0.22),
      Offset(size.width, size.height * 0.3),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TeaserSparklinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
