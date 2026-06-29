import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';

/// Root scaffold for tab screens. Background is owned by [AppShellScreen].
class TabScreenScaffold extends StatelessWidget {
  final Widget body;
  final bool resizeToAvoidBottomInset;

  const TabScreenScaffold({
    super.key,
    required this.body,
    this.resizeToAvoidBottomInset = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: body,
    );
  }
}

/// Optional full-bleed background for tab screens that use a different color.
class TabScreenBackground extends StatelessWidget {
  final Color color;
  final Widget child;

  const TabScreenBackground({
    super.key,
    this.color = AppColors.surfaceGray,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: child,
    );
  }
}
