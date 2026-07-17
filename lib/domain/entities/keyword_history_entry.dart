import 'package:cloud_firestore/cloud_firestore.dart';

/// A keyword the signed-in user has searched on Home.
class KeywordHistoryEntry {
  final String id;
  final String keyword;
  final String normalizedKeyword;
  final String? topicId;
  final int searchCount;
  final DateTime lastSearchedAt;
  final DateTime firstSearchedAt;

  const KeywordHistoryEntry({
    required this.id,
    required this.keyword,
    required this.normalizedKeyword,
    this.topicId,
    required this.searchCount,
    required this.lastSearchedAt,
    required this.firstSearchedAt,
  });

  factory KeywordHistoryEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return KeywordHistoryEntry(
      id: doc.id,
      keyword: data['keyword'] as String? ?? '',
      normalizedKeyword: data['normalizedKeyword'] as String? ?? doc.id,
      topicId: data['topicId'] as String?,
      searchCount: (data['searchCount'] as num?)?.toInt() ?? 1,
      lastSearchedAt: _readTimestamp(data['lastSearchedAt']),
      firstSearchedAt: _readTimestamp(data['firstSearchedAt']),
    );
  }

  factory KeywordHistoryEntry.fromJson(Map<String, dynamic> json) {
    return KeywordHistoryEntry(
      id: json['id'] as String? ?? '',
      keyword: json['keyword'] as String? ?? '',
      normalizedKeyword: json['normalizedKeyword'] as String? ?? '',
      topicId: json['topicId'] as String?,
      searchCount: (json['searchCount'] as num?)?.toInt() ?? 1,
      lastSearchedAt: DateTime.tryParse(json['lastSearchedAt'] as String? ?? '') ??
          DateTime.now(),
      firstSearchedAt:
          DateTime.tryParse(json['firstSearchedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keyword': keyword,
      'normalizedKeyword': normalizedKeyword,
      if (topicId != null) 'topicId': topicId,
      'searchCount': searchCount,
      'lastSearchedAt': lastSearchedAt.toIso8601String(),
      'firstSearchedAt': firstSearchedAt.toIso8601String(),
    };
  }

  static DateTime _readTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }
}

class KeywordHistorySnapshot {
  final List<KeywordHistoryEntry> recent;
  final List<KeywordHistoryEntry> frequent;

  const KeywordHistorySnapshot({
    required this.recent,
    required this.frequent,
  });

  static const empty = KeywordHistorySnapshot(recent: [], frequent: []);

  bool get isEmpty => recent.isEmpty && frequent.isEmpty;
}
