import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/presentation/controllers/tab_bar_ui_controller.dart';
import 'package:synapse/presentation/widgets/app_bottom_nav_bar.dart';
import 'package:synapse/presentation/widgets/navigation/app_bottom_nav_layout.dart';

class AppShellScreen extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShellScreen({super.key, required this.navigationShell});

  @override
  ConsumerState<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends ConsumerState<AppShellScreen>
    with TickerProviderStateMixin {
  late final AnimationController _modeController;
  late final Animation<double> _modeAnimation;

  /// Branch order matches [navigationShell] indices:
  /// 0 Home | 1 Trend | 2 Search (FAB) | 3 Authors | 4 Journals
  static const List<AppBottomNavItem> tabs = [
    AppBottomNavItem(
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      label: 'Home',
    ),
    AppBottomNavItem(
      icon: CupertinoIcons.chart_bar,
      activeIcon: CupertinoIcons.chart_bar_fill,
      label: 'Trend',
    ),
    AppBottomNavItem(
      icon: CupertinoIcons.search,
      activeIcon: CupertinoIcons.search,
      label: 'Search',
      isCenterFab: true,
    ),
    AppBottomNavItem(
      icon: CupertinoIcons.person_2,
      activeIcon: CupertinoIcons.person_2_fill,
      label: 'Authors',
    ),
    AppBottomNavItem(
      icon: CupertinoIcons.book,
      activeIcon: CupertinoIcons.book_fill,
      label: 'Journals',
    ),
  ];

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification &&
        notification is! ScrollEndNotification) {
      return false;
    }

    // Ignore nested scrollables (e.g. autocomplete lists, inner lists).
    if (notification.depth != 0) return false;

    updateTabBarStickyFromScroll(ref, notification.metrics);
    return false;
  }

  void _onStickyChanged(bool? previous, bool next) {
    if (next) {
      _modeController.forward();
    } else {
      _modeController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _modeController = AnimationController(
      vsync: this,
      duration: AppBottomNavLayout.modeAnimationDuration,
    );
    _modeAnimation = CurvedAnimation(
      parent: _modeController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _modeController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != widget.navigationShell.currentIndex) {
      scheduleTabBarSticky(ref, false);
    }
    syncShellTabIndex(ref, index);
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(tabBarStickyProvider, _onStickyChanged);

    final shellIndex = widget.navigationShell.currentIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) syncShellTabIndex(ref, shellIndex);
    });

    return ColoredBox(
      color: AppColors.surfaceGray,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: TabBarModeAnimation(
          animation: _modeAnimation,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onScrollNotification,
                  child: widget.navigationShell,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: RepaintBoundary(
                  child: AppBottomNavBar(
                    modeAnimation: _modeAnimation,
                    currentIndex: widget.navigationShell.currentIndex,
                    onTap: _onTabTapped,
                    items: tabs,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
