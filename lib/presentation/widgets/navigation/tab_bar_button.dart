import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/presentation/widgets/navigation/app_bottom_nav_metrics.dart';

class TabBarButton extends StatelessWidget {
  final String label;
  final bool focused;
  final double labelProgress;
  final IconData icon;
  final IconData activeIcon;
  final VoidCallback onTap;

  const TabBarButton({
    super.key,
    required this.label,
    required this.focused,
    required this.labelProgress,
    required this.icon,
    required this.activeIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = focused ? AppColors.brandBlue600 : AppColors.textLight;
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (focused)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.brandBlue900.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  Icon(
                    focused ? activeIcon : icon,
                    size: 22,
                    color: color,
                  ),
                ],
              ),
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
                          fontSize: 10,
                          height: 1.2,
                          fontWeight: focused
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: color,
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
