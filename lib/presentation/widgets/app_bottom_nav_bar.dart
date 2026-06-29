import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/presentation/controllers/tab_bar_ui_controller.dart';
import 'package:synapse/presentation/widgets/navigation/app_bottom_nav_layout.dart';
import 'package:synapse/presentation/widgets/navigation/center_fab_button.dart';
import 'package:synapse/presentation/widgets/navigation/notched_bar_shape.dart';
import 'package:synapse/presentation/widgets/navigation/tab_bar_button.dart';

class AppBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isCenterFab;

  const AppBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isCenterFab = false,
  });
}

class AppBottomNavBar extends ConsumerWidget {
  final Animation<double> modeAnimation;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  const AppBottomNavBar({
    super.key,
    required this.modeAnimation,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  int? get _centerFabIndex {
    final index = items.indexWhere((item) => item.isCenterFab);
    return index == -1 ? null : index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final suppressed = ref.watch(tabBarSuppressedProvider);
    final hideBar = keyboardVisible || suppressed;
    final centerFabIndex = _centerFabIndex;

    return AnimatedBuilder(
      animation: modeAnimation,
      builder: (context, child) {
        final geometry = AppBottomNavLayout.geometry(
          t: modeAnimation.value,
          bottomInset: bottomInset,
        );
        final centerFabFocused =
            centerFabIndex != null && currentIndex == centerFabIndex;

        return AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          offset: hideBar ? const Offset(0, 1.2) : Offset.zero,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: hideBar ? 0 : 1,
            child: IgnorePointer(
              ignoring: hideBar,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  geometry.horizontalPadding,
                  0,
                  geometry.horizontalPadding,
                  geometry.wrapperBottom,
                ),
                child: SizedBox(
                  height: geometry.totalHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: geometry.pillHeight,
                        child: CustomPaint(
                          painter: NotchedBarPainter(
                            cornerRadius: geometry.cornerRadius,
                            paddingTop: geometry.paddingTop,
                            fillColor: AppColors.background,
                            borderColor: const Color(0xFFE6E4E0),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: geometry.paddingBottom,
                        child: SizedBox(
                          height: geometry.contentHeight,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(items.length, (index) {
                              final item = items[index];

                              if (item.isCenterFab) {
                                return CenterFabButton(
                                  showOrb: false,
                                  focused: currentIndex == index,
                                  labelProgress: geometry.labelProgress,
                                  label: item.label,
                                  onTap: () => onTap(index),
                                );
                              }

                              return TabBarButton(
                                focused: currentIndex == index,
                                labelProgress: geometry.labelProgress,
                                label: item.label,
                                icon: item.icon,
                                activeIcon: item.activeIcon,
                                onTap: () => onTap(index),
                              );
                            }),
                          ),
                        ),
                      ),
                      if (centerFabIndex != null)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom:
                              geometry.pillHeight -
                              geometry.paddingTop -
                              (CenterFabButton.fabSize / 2),
                          child: Center(
                            child: CenterFabOrb(
                              focused: centerFabFocused,
                              onTap: () => onTap(centerFabIndex),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
