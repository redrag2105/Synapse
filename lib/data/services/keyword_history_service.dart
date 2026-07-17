import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synapse/app/utils/app_logger.dart';
import 'package:synapse/domain/entities/keyword_history_entry.dart';

/// Persists keyword searches in memory + SharedPreferences, with optional Firestore sync.
class KeywordHistoryService {
  KeywordHistoryService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Process-lifetime cache so a slow Firestore round-trip can't wipe a fresh save.
  final Map<String, List<KeywordHistoryEntry>> _memory = {};

  static const int _recentLimit = 10;
  static const int _frequentLimit = 3;
  static const String _prefsPrefix = 'keyword_history_v1_';

  CollectionReference<Map<String, dynamic>> _historyRef(String uid) {
    return _db.collection('users').doc(uid).collection('keywordHistory');
  }

  String _prefsKey(String uid) => '$_prefsPrefix$uid';

  /// Upserts a search: memory → disk → best-effort Firestore.
  Future<KeywordHistorySnapshot> recordSearch({
    required String uid,
    required String keyword,
    String? topicId,
  }) async {
    final display = keyword.trim();
    if (display.isEmpty) {
      return fetchHistory(uid, allowRemote: false);
    }

    final normalized = display.toLowerCase();
    final now = DateTime.now();

    // Ensure memory is hydrated before mutating.
    await _ensureMemory(uid);

    final local = List<KeywordHistoryEntry>.from(_memory[uid] ?? const []);
    final existingIndex = local.indexWhere(
      (e) => e.normalizedKeyword == normalized,
    );

    if (existingIndex >= 0) {
      final old = local[existingIndex];
      local[existingIndex] = KeywordHistoryEntry(
        id: old.id,
        keyword: display,
        normalizedKeyword: normalized,
        topicId: topicId?.isNotEmpty == true ? topicId : old.topicId,
        searchCount: old.searchCount + 1,
        lastSearchedAt: now,
        firstSearchedAt: old.firstSearchedAt,
      );
    } else {
      local.add(
        KeywordHistoryEntry(
          id: _docIdFor(normalized),
          keyword: display,
          normalizedKeyword: normalized,
          topicId: topicId?.isNotEmpty == true ? topicId : null,
          searchCount: 1,
          lastSearchedAt: now,
          firstSearchedAt: now,
        ),
      );
    }

    _memory[uid] = local;
    await _saveLocal(uid, local);
    AppLogger.i('Saved keyword history locally: "$display" (${local.length} total)');

    // Don't block UI on Firestore.
    unawaitedFirestoreSync(
      uid: uid,
      display: display,
      normalized: normalized,
      topicId: topicId,
    );

    return _snapshotFrom(local);
  }

  Future<KeywordHistorySnapshot> fetchHistory(
    String uid, {
    bool allowRemote = true,
  }) async {
    await _ensureMemory(uid);
    final cached = _memory[uid] ?? const <KeywordHistoryEntry>[];

    if (!allowRemote) {
      return _snapshotFrom(cached);
    }

    // Return local immediately-quality data; optionally enrich from remote.
    try {
      final recentFuture = _historyRef(uid)
          .orderBy('lastSearchedAt', descending: true)
          .limit(_recentLimit)
          .get();
      final frequentFuture = _historyRef(uid)
          .orderBy('searchCount', descending: true)
          .limit(_frequentLimit)
          .get();

      final results = await Future.wait([recentFuture, frequentFuture]);
      final remote = <KeywordHistoryEntry>[
        ...results[0].docs.map(KeywordHistoryEntry.fromFirestore),
        ...results[1].docs.map(KeywordHistoryEntry.fromFirestore),
      ];

      if (remote.isNotEmpty) {
        // Re-read memory after await — a search may have landed meanwhile.
        final latestLocal = _memory[uid] ?? await _loadLocal(uid);
        final merged = _mergeEntries(latestLocal, remote);
        _memory[uid] = merged;
        await _saveLocal(uid, merged);
        return _snapshotFrom(merged);
      }
    } catch (e, st) {
      AppLogger.w('Remote keyword history unavailable; using local', e);
      AppLogger.d(st.toString());
    }

    // Re-read after await so we never return a stale empty pre-save snapshot.
    await _ensureMemory(uid);
    return _snapshotFrom(_memory[uid] ?? const []);
  }

  Future<void> _ensureMemory(String uid) async {
    if (_memory.containsKey(uid)) return;
    _memory[uid] = await _loadLocal(uid);
  }

  void unawaitedFirestoreSync({
    required String uid,
    required String display,
    required String normalized,
    String? topicId,
  }) {
    () async {
      try {
        final docRef = _historyRef(uid).doc(_docIdFor(normalized));
        await _db.runTransaction((tx) async {
          final snap = await tx.get(docRef);
          final serverNow = FieldValue.serverTimestamp();

          if (!snap.exists) {
            tx.set(docRef, {
              'keyword': display,
              'normalizedKeyword': normalized,
              if (topicId != null && topicId.isNotEmpty) 'topicId': topicId,
              'searchCount': 1,
              'lastSearchedAt': serverNow,
              'firstSearchedAt': serverNow,
            });
            return;
          }

          final updates = <String, Object?>{
            'keyword': display,
            'normalizedKeyword': normalized,
            'searchCount': FieldValue.increment(1),
            'lastSearchedAt': serverNow,
          };
          if (topicId != null && topicId.isNotEmpty) {
            updates['topicId'] = topicId;
          }
          tx.update(docRef, updates);
        });
      } catch (e, st) {
        AppLogger.w(
          'Firestore keyword sync failed for "$display" (local copy kept)',
          e,
        );
        AppLogger.d(st.toString());
      }
    }();
  }

  KeywordHistorySnapshot _snapshotFrom(List<KeywordHistoryEntry> entries) {
    if (entries.isEmpty) return KeywordHistorySnapshot.empty;

    final recent = List<KeywordHistoryEntry>.from(entries)
      ..sort((a, b) => b.lastSearchedAt.compareTo(a.lastSearchedAt));
    final frequent = List<KeywordHistoryEntry>.from(entries)
      ..sort((a, b) {
        final byCount = b.searchCount.compareTo(a.searchCount);
        if (byCount != 0) return byCount;
        return b.lastSearchedAt.compareTo(a.lastSearchedAt);
      });

    return KeywordHistorySnapshot(
      recent: recent.take(_recentLimit).toList(),
      frequent: frequent.take(_frequentLimit).toList(),
    );
  }

  List<KeywordHistoryEntry> _mergeEntries(
    List<KeywordHistoryEntry> local,
    List<KeywordHistoryEntry> remote,
  ) {
    final byKey = <String, KeywordHistoryEntry>{};
    for (final entry in [...local, ...remote]) {
      if (entry.normalizedKeyword.isEmpty) continue;
      final existing = byKey[entry.normalizedKeyword];
      if (existing == null) {
        byKey[entry.normalizedKeyword] = entry;
        continue;
      }
      byKey[entry.normalizedKeyword] = KeywordHistoryEntry(
        id: existing.id.isNotEmpty ? existing.id : entry.id,
        keyword: entry.lastSearchedAt.isAfter(existing.lastSearchedAt)
            ? entry.keyword
            : existing.keyword,
        normalizedKeyword: entry.normalizedKeyword,
        topicId: entry.topicId ?? existing.topicId,
        searchCount: entry.searchCount > existing.searchCount
            ? entry.searchCount
            : existing.searchCount,
        lastSearchedAt: entry.lastSearchedAt.isAfter(existing.lastSearchedAt)
            ? entry.lastSearchedAt
            : existing.lastSearchedAt,
        firstSearchedAt:
            entry.firstSearchedAt.isBefore(existing.firstSearchedAt)
            ? entry.firstSearchedAt
            : existing.firstSearchedAt,
      );
    }
    return byKey.values.toList();
  }

  Future<List<KeywordHistoryEntry>> _loadLocal(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey(uid));
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      return decoded
          .map((item) {
            if (item is Map<String, dynamic>) {
              return KeywordHistoryEntry.fromJson(item);
            }
            if (item is Map) {
              return KeywordHistoryEntry.fromJson(
                Map<String, dynamic>.from(item),
              );
            }
            return null;
          })
          .whereType<KeywordHistoryEntry>()
          .where((e) => e.keyword.isNotEmpty)
          .toList();
    } catch (e, st) {
      AppLogger.w('Failed to read local keyword history', e);
      AppLogger.d(st.toString());
      return [];
    }
  }

  Future<void> _saveLocal(String uid, List<KeywordHistoryEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
      final ok = await prefs.setString(_prefsKey(uid), encoded);
      if (!ok) {
        AppLogger.w('SharedPreferences rejected keyword history write');
      }
    } catch (e, st) {
      AppLogger.w('Failed to write local keyword history', e);
      AppLogger.d(st.toString());
    }
  }

  static String _docIdFor(String normalizedKeyword) {
    final sanitized = normalizedKeyword
        .replaceAll(RegExp(r'[^\w.\-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    if (sanitized.isEmpty) return 'keyword';
    return sanitized.length > 120 ? sanitized.substring(0, 120) : sanitized;
  }
}
