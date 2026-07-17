import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';

class ProfileSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const ProfileSectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h3.copyWith(color: AppColors.brandBlue900),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTextStyles.metadata.copyWith(fontSize: 12, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class ProfileSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ProfileSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: child,
    );
  }
}

class ProfileMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ProfileMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.brandBlue600),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppTextStyles.h3.copyWith(color: AppColors.brandBlue900),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.metadata.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
