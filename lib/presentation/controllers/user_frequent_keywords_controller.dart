import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/app/utils/app_logger.dart';
import 'package:synapse/domain/entities/keyword_entity.dart';
import 'package:synapse/domain/entities/keyword_history_entry.dart';
import 'package:synapse/domain/entities/topic_entity.dart';
import 'package:synapse/presentation/controllers/app_remote_config_controller.dart';
import 'package:synapse/presentation/controllers/auth_providers.dart';
import 'package:synapse/presentation/controllers/keyword_history_providers.dart';

/// Personalized Keywords-tab data from the signed-in user's search history.
class UserFrequentKeywordsState {
  final bool isSignedIn;
  final int uniqueSearchCount;
  final int displayCount;
  final List<KeywordEntity> keywords;
  /// Parallel to [keywords] — how many times the user searched each topic.
  final List<int> searchCounts;

  const UserFrequentKeywordsState({
    required this.isSignedIn,
    required this.uniqueSearchCount,
    required this.displayCount,
    required this.keywords,
    this.searchCounts = const [],
  });

  static const guest = UserFrequentKeywordsState(
    isSignedIn: false,
    uniqueSearchCount: 0,
    displayCount: 0,
    keywords: [],
  );

  static const signedInEmpty = UserFrequentKeywordsState(
    isSignedIn: true,
    uniqueSearchCount: 0,
    displayCount: 0,
    keywords: [],
  );

  KeywordEntity? get topKeyword => keywords.isEmpty ? null : keywords.first;

  int get topSearchCount =>
      searchCounts.isEmpty ? 0 : searchCounts.first;

  bool get isEmpty => keywords.isEmpty;
}

final userFrequentKeywordsProvider =
    AsyncNotifierProvider.autoDispose<
      UserFrequentKeywordsController,
      UserFrequentKeywordsState
    >(UserFrequentKeywordsController.new);

class UserFrequentKeywordsController
    extends AsyncNotifier<UserFrequentKeywordsState> {
  @override
  Future<UserFrequentKeywordsState> build() async {
    final user = ref.watch(currentUserProvider);
    final maxDisplay = ref.watch(appRemoteConfigProvider).maxKeywordsDisplay;

    // Rebuild when history updates (new Home searches).
    ref.watch(keywordHistoryProvider);

    ref.listen(appRemoteConfigProvider, (previous, next) {
      if (previous != null &&
          previous.maxKeywordsDisplay != next.maxKeywordsDisplay) {
        ref.invalidateSelf();
      }
    });

    if (user == null) {
      return UserFrequentKeywordsState.guest;
    }

    final historyService = ref.read(keywordHistoryServiceProvider);
    final uniqueCount = await historyService.uniqueKeywordCount(user.uid);
    if (uniqueCount == 0) {
      return UserFrequentKeywordsState.signedInEmpty;
    }

    final limit = maxDisplay.clamp(1, 200);
    final displayCount = uniqueCount < limit ? uniqueCount : limit;
    final ranked = await historyService.fetchRankedByFrequency(
      user.uid,
      limit: displayCount,
    );

    final keywords = await _enrichWithWorksCounts(ranked);
    AppLogger.i(
      'Personalized keywords: ${keywords.length} of $uniqueCount '
      '(cap $limit); works='
      '${keywords.map((k) => k.worksCount).join(",")}',
    );

    return UserFrequentKeywordsState(
      isSignedIn: true,
      uniqueSearchCount: uniqueCount,
      displayCount: displayCount,
      keywords: keywords,
      searchCounts: ranked.map((e) => e.searchCount).toList(growable: false),
    );
  }

  /// Home searches store OpenAlex *topics* — resolve works_count via Topics API.
  Future<List<KeywordEntity>> _enrichWithWorksCounts(
    List<KeywordHistoryEntry> entries,
  ) async {
    final topicRepo = ref.read(topicRepositoryProvider);
    final enriched = await Future.wait(
      entries.map((entry) async {
        final topicId = entry.topicId?.trim();
        if (topicId != null && topicId.isNotEmpty) {
          final byId = await topicRepo.getTopicById(topicId);
          final matched = byId.fold((_) => null, (t) => t);
          if (matched != null && matched.worksCount > 0) {
            return KeywordEntity(
              id: matched.id,
              displayName: entry.keyword,
              worksCount: matched.worksCount,
            );
          }
        }

        final search = await topicRepo.searchTopics(entry.keyword, limit: 5);
        final match = search.fold<TopicEntity?>((_) => null, (list) {
          if (list.isEmpty) return null;
          final normalized = entry.normalizedKeyword;
          for (final candidate in list) {
            if (candidate.displayName.trim().toLowerCase() == normalized) {
              return candidate;
            }
          }
          return list.first;
        });

        if (match != null) {
          return KeywordEntity(
            id: match.id,
            displayName: entry.keyword,
            worksCount: match.worksCount,
          );
        }

        AppLogger.w(
          'No OpenAlex topic works_count for "${entry.keyword}"',
        );
        return KeywordEntity(
          id: topicId ?? entry.id,
          displayName: entry.keyword,
          worksCount: 0,
        );
      }),
    );

    return enriched;
  }
}
