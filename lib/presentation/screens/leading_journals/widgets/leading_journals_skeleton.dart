import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Loading placeholder mirroring the four Leading Journals sections.
class LeadingJournalsSkeleton extends StatelessWidget {
  const LeadingJournalsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(height: 20, width: 120, radius: 6),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: List.generate(4, (_) => _box(height: 105)),
            ),
            const SizedBox(height: 24),
            _box(height: 320),
            const SizedBox(height: 24),
            _box(height: 20, width: 160, radius: 6),
            const SizedBox(height: 12),
            _box(height: 300),
            const SizedBox(height: 24),
            _box(height: 20, width: 180, radius: 6),
            const SizedBox(height: 12),
            ...List.generate(5, (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _box(height: 64, radius: 12),
                )),
          ],
        ),
      ),
    );
  }

  Widget _box({
    required double height,
    double? width,
    double radius = 16,
  }) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
