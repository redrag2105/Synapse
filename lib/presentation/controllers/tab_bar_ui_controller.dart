import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabBarStickyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setSticky(bool value) {
    if (state != value) state = value;
  }
}

/// When true the tab bar is in compact sticky mode (user scrolled to bottom).
final tabBarStickyProvider =
    NotifierProvider<TabBarStickyNotifier, bool>(TabBarStickyNotifier.new);

const double tabBarScrollBottomThreshold = 15;

bool isScrollAtBottom(ScrollMetrics metrics) {
  if (metrics.maxScrollExtent <= 0) return false;
  return metrics.pixels >= metrics.maxScrollExtent - tabBarScrollBottomThreshold;
}

/// Defers provider writes to after the current frame (safe from notifications/build).
void scheduleTabBarSticky(WidgetRef ref, bool value) {
  if (ref.read(tabBarStickyProvider) == value) return;

  SchedulerBinding.instance.addPostFrameCallback((_) {
    ref.read(tabBarStickyProvider.notifier).setSticky(value);
  });
}

void updateTabBarStickyFromScroll(WidgetRef ref, ScrollMetrics metrics) {
  final atBottom = isScrollAtBottom(metrics);
  if (ref.read(tabBarStickyProvider) == atBottom) return;
  scheduleTabBarSticky(ref, atBottom);
}
