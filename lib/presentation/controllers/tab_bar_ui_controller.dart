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

class TabBarSuppressedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setSuppressed(bool value) {
    if (state != value) state = value;
  }
}

/// Hides the shell tab bar while a screen search field is focused.
final tabBarSuppressedProvider =
    NotifierProvider<TabBarSuppressedNotifier, bool>(
      TabBarSuppressedNotifier.new,
    );

void updateTabBarSuppressed(WidgetRef ref, bool suppressed) {
  ref.read(tabBarSuppressedProvider.notifier).setSuppressed(suppressed);
}

/// Shell branch indices — must match [StatefulShellRoute] branch order in [app_routes].
abstract final class ShellTabIndex {
  static const int keywords = 0;
  static const int authors = 1;
  static const int home = 2;
  static const int journals = 3;
  static const int profile = 4;
}

class ShellTabIndexNotifier extends Notifier<int> {
  @override
  int build() => ShellTabIndex.home;

  void setIndex(int index) {
    if (state != index) state = index;
  }
}

/// Currently visible shell tab (updated by [AppShellScreen]).
final shellTabIndexProvider =
    NotifierProvider<ShellTabIndexNotifier, int>(ShellTabIndexNotifier.new);

void syncShellTabIndex(WidgetRef ref, int index) {
  ref.read(shellTabIndexProvider.notifier).setIndex(index);
}

class ShellKeywordIntent {
  final int targetTab;
  final String keyword;

  const ShellKeywordIntent({
    required this.targetTab,
    required this.keyword,
  });
}

class ShellKeywordIntentNotifier extends Notifier<ShellKeywordIntent?> {
  @override
  ShellKeywordIntent? build() => null;

  void dispatch(int targetTab, String keyword) {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;
    state = ShellKeywordIntent(targetTab: targetTab, keyword: trimmed);
  }

  void clear() {
    if (state != null) state = null;
  }
}

/// Cross-tab keyword navigation (e.g. Research Insights FAB → Trend / Authors / Journals).
final shellKeywordIntentProvider =
    NotifierProvider<ShellKeywordIntentNotifier, ShellKeywordIntent?>(
      ShellKeywordIntentNotifier.new,
    );
