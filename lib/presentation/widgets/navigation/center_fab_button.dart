import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/presentation/widgets/navigation/app_bottom_nav_metrics.dart';

class CenterFabOrb extends StatefulWidget {
  final bool focused;
  final VoidCallback onTap;
  final IconData icon;
  final IconData activeIcon;

  const CenterFabOrb({
    super.key,
    required this.focused,
    required this.onTap,
    this.icon = Icons.home_rounded,
    this.activeIcon = Icons.home_rounded,
  });

  @override
  State<CenterFabOrb> createState() => _CenterFabOrbState();
}

class _CenterFabOrbState extends State<CenterFabOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    if (widget.focused) {
      _rippleController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CenterFabOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focused && !oldWidget.focused) {
      _rippleController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = widget.focused;
    final iconColor = isFocused
        ? Colors.white
        : AppColors.brandBlue900.withValues(alpha: 0.7);

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // RADAR PULSE
          AnimatedBuilder(
            animation: _rippleController,
            builder: (context, child) {
              final progress = _rippleController.value;
              if (!isFocused || progress == 0.0 || progress == 1.0) {
                return const SizedBox.shrink();
              }
              return Transform.scale(
                scale: 1.0 + (progress * 0.3),
                child: Opacity(
                  opacity: (1.0 - progress) * 0.4,
                  child: Container(
                    width: CenterFabButton.fabSize,
                    height: CenterFabButton.fabSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.brandBlue900,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // OUTER BEZEL
          Container(
            width: CenterFabButton.fabSize,
            height: CenterFabButton.fabSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFE2E8F0)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandBlue900.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 4,
                  offset: const Offset(-2, -2),
                ),
              ],
            ),

            // INNER CORE
            child: Padding(
              padding: const EdgeInsets.all(2.5),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isFocused
                      ? const LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            AppColors.brandBlue600,
                            AppColors.brandBlue900,
                          ],
                        )
                      : const LinearGradient(
                          begin: Alignment.bottomRight,
                          end: Alignment.topLeft,
                          colors: [Colors.white, Color(0xFFF8FAFC)],
                        ),
                  boxShadow: isFocused
                      ? [
                          BoxShadow(
                            color: AppColors.brandBlue900.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            spreadRadius: -1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),

                // ICON
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: isFocused ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  builder: (context, rotation, child) {
                    return Transform.rotate(
                      angle: rotation * math.pi * 2,
                      child: Icon(
                        isFocused ? widget.activeIcon : widget.icon,
                        size: CenterFabButton.fabIconSize + (rotation * 2),
                        color: iconColor,
                        fontWeight: FontWeight.w800,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
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

  static const double fabSize = 58;
  static const double fabIconSize = 28;
  static const double fabLift = 34;

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
    final labelColor = focused ? AppColors.brandBlue900 : AppColors.textLight;
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
                          child: CenterFabOrb(focused: focused, onTap: onTap),
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
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.metadata.copyWith(
                          fontSize: 11,
                          height: 1.2,
                          fontWeight: focused
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: labelColor,
                          letterSpacing: 0.5,
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
