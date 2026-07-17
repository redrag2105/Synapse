import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/utils/app_logger.dart';
import 'package:synapse/data/services/keyword_history_service.dart';
import 'package:synapse/domain/entities/keyword_history_entry.dart';
import 'package:synapse/presentation/controllers/auth_providers.dart';

final keywordHistoryServiceProvider = Provider<KeywordHistoryService>((ref) {
  return KeywordHistoryService();
});

/// Keep-alive history store. Uses [Notifier] (not AsyncNotifier) so a slow
/// initial load cannot overwrite a newer [record] result.
final keywordHistoryProvider = NotifierProvider<KeywordHistoryController,
    AsyncValue<KeywordHistorySnapshot?>>(KeywordHistoryController.new);

class KeywordHistoryController
    extends Notifier<AsyncValue<KeywordHistorySnapshot?>> {
  @override
  AsyncValue<KeywordHistorySnapshot?> build() {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const AsyncValue.data(null);
    }

    // Survive Home search ↔ empty transitions.
    ref.keepAlive();

    // Fire-and-forget hydrate from local memory/disk.
    Future.microtask(() => _hydrate(user.uid));

    return const AsyncValue.loading();
  }

  Future<void> _hydrate(String uid) async {
    try {
      final snapshot = await ref
          .read(keywordHistoryServiceProvider)
          .fetchHistory(uid, allowRemote: false);
      // Don't clobber a newer record() that landed while we were loading.
      final current = state.asData?.value;
      if (current != null && !current.isEmpty) {
        return;
      }
      state = AsyncValue.data(snapshot);

      // Best-effort remote enrich in the background.
      final enriched = await ref
          .read(keywordHistoryServiceProvider)
          .fetchHistory(uid, allowRemote: true);
      // Never replace a non-empty in-session list with an empty remote result.
      if (enriched.isEmpty) return;
      final latest = state.asData?.value;
      if (latest != null &&
          !latest.isEmpty &&
          enriched.recent.length < latest.recent.length) {
        return;
      }
      state = AsyncValue.data(enriched);
    } catch (e, st) {
      AppLogger.w('Keyword history hydrate failed', e);
      AppLogger.d(st.toString());
      if (state is! AsyncData) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> record({
    required String keyword,
    String? topicId,
  }) async {
    final user =
        ref.read(currentUserProvider) ?? FirebaseAuth.instance.currentUser;
    if (user == null) {
      AppLogger.w('Skipped keyword history record — user not signed in');
      return;
    }

    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;

    try {
      final snapshot = await ref
          .read(keywordHistoryServiceProvider)
          .recordSearch(
            uid: user.uid,
            keyword: trimmed,
            topicId: topicId,
          );
      state = AsyncValue.data(snapshot);
      AppLogger.i(
        'Keyword history updated in UI (${snapshot.recent.length} recent)',
      );
    } catch (e, st) {
      AppLogger.w('Keyword history record failed', e);
      AppLogger.d(st.toString());
    }
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }
    state = const AsyncValue.loading();
    await _hydrate(user.uid);
  }
}
