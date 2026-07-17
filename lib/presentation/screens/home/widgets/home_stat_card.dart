import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';

enum HomeStatAccent { none, blueWash, goldWash }

/// Compact metric tile for short numeric / year values on Home.
class HomeStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPlaceholder;
  final HomeStatAccent accent;
  final VoidCallback? onTap;

  static const double minCardHeight = 96;

  const HomeStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isPlaceholder = false,
    this.accent = HomeStatAccent.none,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: minCardHeight),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          gradient: _gradient(),
          color: accent == HomeStatAccent.none ? AppColors.surfaceGray : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor()),
          boxShadow: accent == HomeStatAccent.none
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: _iconColor()),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.metadata.copyWith(
                      fontSize: 11,
                      height: 1.2,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.h3.copyWith(
                color: isPlaceholder
                    ? AppColors.borderGray
                    : AppColors.brandBlue900,
                fontSize: value.length > 14 ? 15 : 20,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return content;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }

  LinearGradient? _gradient() {
    return switch (accent) {
      HomeStatAccent.blueWash => LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.3),
          AppColors.brandBlue700.withValues(alpha: 0.14),
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ),
      HomeStatAccent.goldWash => LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.3),
          AppColors.brandGold.withValues(alpha: 0.18),
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ),
      HomeStatAccent.none => null,
    };
  }

  Color _borderColor() {
    return switch (accent) {
      HomeStatAccent.blueWash => AppColors.brandBlue600.withValues(alpha: 0.18),
      HomeStatAccent.goldWash => AppColors.brandGold.withValues(alpha: 0.35),
      HomeStatAccent.none => AppColors.borderGray.withValues(alpha: 0.6),
    };
  }

  Color _iconColor() {
    final alpha = isPlaceholder ? 0.55 : 0.9;
    return switch (accent) {
      HomeStatAccent.goldWash => AppColors.brandGold.withValues(alpha: alpha),
      _ => AppColors.brandBlue700.withValues(alpha: alpha),
    };
  }
}

/// Full-width insight row for long names (author / journal) — no fixed height.
class HomeFeaturedStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? meta;
  final bool isLoading;
  final bool useGradient;
  final VoidCallback? onTap;

  const HomeFeaturedStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.meta,
    this.isLoading = false,
    this.useGradient = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: useGradient
            ? LinearGradient(
                colors: [
                  AppColors.brandBlue900.withValues(alpha: 0.001),
                  AppColors.brandBlue700.withValues(alpha: 0.14),
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topRight,
              )
            : null,
        color: useGradient ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: useGradient
              ? AppColors.brandBlue600.withValues(alpha: 0.18)
              : AppColors.borderGray.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.brandBlue900.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.brandBlue900),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.metadata.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLoading ? '…' : value,
                  // No fixed card height — wrap fully so long names aren't clipped.
                  softWrap: true,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 15,
                    height: 1.35,
                    color: AppColors.brandBlue900,
                    fontFamily: 'Merriweather',
                  ),
                ),
                if (meta != null && meta!.isNotEmpty && !isLoading) ...[
                  const SizedBox(height: 4),
                  Text(
                    meta!,
                    style: AppTextStyles.metadata.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            const Padding(
              padding: EdgeInsets.only(left: 4, top: 2),
              child: Icon(
                CupertinoIcons.arrow_up_right,
                size: 16,
                color: AppColors.textLight,
              ),
            ),
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: content,
      ),
    );
  }
}
