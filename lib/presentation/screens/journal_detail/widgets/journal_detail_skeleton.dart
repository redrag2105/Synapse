import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class JournalDetailSkeleton extends StatelessWidget {
  const JournalDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.white,
        child: Column(
          children: [
            Container(height: 260, color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _box(height: 100)),
                      const SizedBox(width: 12),
                      Expanded(child: _box(height: 100)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _box(height: 100)),
                      const SizedBox(width: 12),
                      Expanded(child: _box(height: 100)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _box(height: 300),
                  const SizedBox(height: 16),
                  _box(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
