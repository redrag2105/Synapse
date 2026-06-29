import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/presentation/widgets/navigation/app_bottom_nav_metrics.dart';

/// The elevated circular search button (rendered above the tab bar).
class CenterFabOrb extends StatelessWidget {
  final bool focused;
  final VoidCallback onTap;

  const CenterFabOrb({
    super.key,
    required this.focused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = focused ? AppColors.brandBlue900 : AppColors.brandBlue500;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder<double>(
        key: ValueKey('fab-orb-$focused'),
        tween: Tween(end: focused ? 1.0 : 0.95),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: focused ? AppColors.surfaceGray : AppColors.background,
                border: Border.all(
                  color: accent.withValues(alpha: focused ? 0.35 : 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: focused ? 0.22 : 0.08),
                    blurRadius: focused ? 14 : 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                width: CenterFabButton.fabSize,
                height: CenterFabButton.fabSize,
                child: Icon(
                  Icons.search_rounded,
                  size: CenterFabButton.fabIconSize,
                  color: accent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Center tab slot: label + tap target aligned with other tabs.
class CenterFabButton extends StatelessWidget {
  final bool focused;
  final double labelProgress;
  final bool showOrb;
  final String label;
  final VoidCallback onTap;

  static const double fabSize = 64;
  static const double fabIconSize = 28;
  static const double fabLift = 40;

  /// Clearance above the pill so the FAB orb is not clipped.
  static const double topOverflow = 48;

  const CenterFabButton({
    super.key,
    required this.focused,
    required this.labelProgress,
    this.showOrb = true,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = focused ? AppColors.brandBlue900 : AppColors.textLight;
    final labelHeight =
        AppBottomNavMetrics.labelSlotHeight * labelProgress.clamp(0.0, 1.0);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: AppBottomNavMetrics.iconSlotHeight,
              height: AppBottomNavMetrics.iconSlotHeight,
              child: showOrb
                  ? Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned(
                          top: -fabLift,
                          child: CenterFabOrb(
                            focused: focused,
                            onTap: onTap,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            SizedBox(
              height: labelHeight,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: labelProgress.clamp(0.001, 1.0),
                  child: Opacity(
                    opacity: labelProgress.clamp(0.0, 1.0),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.metadata.copyWith(
                          fontSize: 11,
                          height: 1.2,
                          fontWeight:
                              focused ? FontWeight.w600 : FontWeight.w500,
                          color: accent,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
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
