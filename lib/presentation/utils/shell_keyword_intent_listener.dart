import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/presentation/controllers/tab_bar_ui_controller.dart';

/// Wires a shell tab to [shellKeywordIntentProvider] so FAB / cross-tab
/// navigation can push a keyword into an already-mounted tab screen.
void bindShellKeywordIntent({
  required WidgetRef ref,
  required int tabIndex,
  required void Function(String keyword) onKeyword,
}) {
  ref.listen<ShellKeywordIntent?>(shellKeywordIntentProvider, (_, _) {
    _consumeShellKeywordIntent(
      ref: ref,
      tabIndex: tabIndex,
      onKeyword: onKeyword,
    );
  });

  ref.listen<int>(shellTabIndexProvider, (_, _) {
    _consumeShellKeywordIntent(
      ref: ref,
      tabIndex: tabIndex,
      onKeyword: onKeyword,
    );
  });
}

void scheduleShellKeywordIntentConsumption({
  required WidgetRef ref,
  required int tabIndex,
  required void Function(String keyword) onKeyword,
}) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    _consumeShellKeywordIntent(
      ref: ref,
      tabIndex: tabIndex,
      onKeyword: onKeyword,
    );
  });
}

void _consumeShellKeywordIntent({
  required WidgetRef ref,
  required int tabIndex,
  required void Function(String keyword) onKeyword,
}) {
  if (ref.read(shellTabIndexProvider) != tabIndex) return;

  final intent = ref.read(shellKeywordIntentProvider);
  if (intent == null || intent.targetTab != tabIndex) return;

  onKeyword(intent.keyword);
  ref.read(shellKeywordIntentProvider.notifier).clear();
}
