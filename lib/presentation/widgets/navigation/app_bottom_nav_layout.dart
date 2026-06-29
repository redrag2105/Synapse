import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:synapse/presentation/widgets/navigation/app_bottom_nav_metrics.dart';
import 'package:synapse/presentation/widgets/navigation/center_fab_button.dart';

/// Interpolated layout for floating (t=0) ↔ sticky (t=1) tab bar modes.
class AppBottomNavLayout {
  AppBottomNavLayout._();

  static const double expandedHorizontalPadding = 20;
  static const double expandedCornerRadius = 25;
  static const Duration modeAnimationDuration = Duration(milliseconds: 270);

  static double lerp(double expanded, double sticky, double t) {
    return expanded + (sticky - expanded) * t;
  }

  static AppBottomNavGeometry geometry({
    required double t,
    required double bottomInset,
  }) {
    final clamped = t.clamp(0.0, 1.0);
    final horizontalPadding = lerp(expandedHorizontalPadding, 0, clamped);
    final cornerRadius = lerp(expandedCornerRadius, 0, clamped);
    final paddingTop = lerp(8, 10, clamped);
    final labelProgress = 1 - clamped;
    final contentHeight =
        AppBottomNavMetrics.iconSlotHeight +
        (AppBottomNavMetrics.labelSlotHeight * labelProgress);
    final paddingBottom = bottomInset > 0 ? bottomInset : 8.0;
    final pillHeight = paddingTop + contentHeight + paddingBottom;
    final wrapperBottom = lerp(
      math.max(bottomInset - 15, 12).toDouble(),
      0,
      clamped,
    );
    final totalHeight = CenterFabButton.topOverflow + pillHeight;
    final overlayInset = wrapperBottom + pillHeight + 16;

    return AppBottomNavGeometry(
      horizontalPadding: horizontalPadding,
      cornerRadius: cornerRadius,
      paddingTop: paddingTop,
      contentHeight: contentHeight,
      labelProgress: labelProgress,
      paddingBottom: paddingBottom,
      pillHeight: pillHeight,
      wrapperBottom: wrapperBottom,
      totalHeight: totalHeight,
      overlayInset: overlayInset,
    );
  }

  /// Largest footer clearance across floating and sticky modes — stable for scroll padding.
  static double maxOverlayInset(double bottomInset) {
    final expanded = geometry(t: 0, bottomInset: bottomInset).overlayInset;
    final sticky = geometry(t: 1, bottomInset: bottomInset).overlayInset;
    return math.max(expanded, sticky);
  }
}

class AppBottomNavGeometry {
  final double horizontalPadding;
  final double cornerRadius;
  final double paddingTop;
  final double contentHeight;
  final double labelProgress;
  final double paddingBottom;
  final double pillHeight;
  final double wrapperBottom;
  final double totalHeight;
  final double overlayInset;

  const AppBottomNavGeometry({
    required this.horizontalPadding,
    required this.cornerRadius,
    required this.paddingTop,
    required this.contentHeight,
    required this.labelProgress,
    required this.paddingBottom,
    required this.pillHeight,
    required this.wrapperBottom,
    required this.totalHeight,
    required this.overlayInset,
  });
}

/// Bottom spacer so scroll content clears the floating tab bar.
class TabBarContentPadding extends StatelessWidget {
  final double extra;

  const TabBarContentPadding({super.key, this.extra = 0});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SizedBox(
      height: AppBottomNavLayout.maxOverlayInset(bottomInset) + extra,
    );
  }
}

/// Inherited animation: 0 = expanded floating, 1 = sticky compact.
class TabBarModeAnimation extends InheritedWidget {
  final Animation<double> animation;

  const TabBarModeAnimation({
    super.key,
    required this.animation,
    required super.child,
  });

  static Animation<double> of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<TabBarModeAnimation>();
    assert(scope != null, 'TabBarModeAnimation not found in context');
    return scope!.animation;
  }

  /// Current scroll/footer clearance for the tab bar (animated).
  static double overlayInsetOf(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return AppBottomNavLayout.geometry(
      t: of(context).value,
      bottomInset: bottomInset,
    ).overlayInset;
  }

  @override
  bool updateShouldNotify(TabBarModeAnimation oldWidget) {
    return animation != oldWidget.animation;
  }
}
