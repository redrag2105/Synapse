import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synapse/app/config/app_colors.dart';

class PublicationDetailSkeleton extends StatelessWidget {
  const PublicationDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.brandBlue900, AppColors.brandBlue900],
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [_buildBannerSkeleton(), _buildContentSkeleton()],
          ),
        ),
      ],
    );
  }

  // 1. SKELETON CHO VÙNG MÀU XANH
  Widget _buildBannerSkeleton() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.brandBlue900, AppColors.brandBlue700],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: 0.1),
        highlightColor: Colors.white.withValues(alpha: 0.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề (3 dòng)
            Container(width: double.infinity, height: 32, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: double.infinity, height: 32, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 200, height: 32, color: Colors.white),
            const SizedBox(height: 24),

            // Tags & Volume
            Container(width: 250, height: 16, color: Colors.white),
            const SizedBox(height: 12),
            Container(width: 150, height: 16, color: Colors.white),
            const SizedBox(height: 24),

            // Các nút bấm
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. SKELETON CHO VÙNG NỘI DUNG TRẮNG
  Widget _buildContentSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      // Shimmer trên nền sáng -> Dùng màu xám nhạt
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Authors
            Container(width: double.infinity, height: 16, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 180, height: 16, color: Colors.white),
            const SizedBox(height: 24),

            // Metrics
            Row(
              children: [
                Container(width: 24, height: 24, color: Colors.white),
                const SizedBox(width: 8),
                Container(width: 100, height: 20, color: Colors.white),
              ],
            ),
            const SizedBox(height: 32),

            // Abstract
            Container(width: 120, height: 24, color: Colors.white),
            const SizedBox(height: 16),
            for (int i = 0; i < 6; i++) ...[
              Container(
                width: double.infinity,
                height: 16,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
            ],
            Container(width: 200, height: 16, color: Colors.white),
            const SizedBox(height: 40),

            // Concepts
            Container(width: 120, height: 24, color: Colors.white),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: List.generate(
                6,
                (index) => Container(
                  width: 80 + (index * 15.0 % 40),
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
