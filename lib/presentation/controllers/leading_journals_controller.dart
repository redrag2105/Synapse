import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/types/paginated_list_state.dart';
import 'package:synapse/domain/entities/top_journals_page.dart';
import 'package:synapse/domain/entities/leading_journal_entity.dart';
import 'package:synapse/domain/usecases/journal/get_top_journals_usecase.dart';
import 'package:synapse/presentation/widgets/pagination_footer.dart';

final leadingJournalsControllerProvider = AsyncNotifierProvider<
    LeadingJournalsController, LeadingJournalsOverview>(
  LeadingJournalsController.new,
);

class LeadingJournalsController extends AsyncNotifier<LeadingJournalsOverview> {
  static const int _pageSize = PaginatedListState.defaultPageSize;

  static const LeadingJournalsOverview emptyOverview = LeadingJournalsOverview(
    journals: [],
    insights: LeadingJournalInsights(
      activeJournals: 0,
      mostProlificJournal: '—',
      mostProlificCount: 0,
      highestImpactJournal: '—',
      highestImpactHIndex: 0,
      avgCitations: 0,
    ),
    quartileDistribution: JournalQuartileDistribution(
      q1Percent: 0,
      q2Percent: 0,
      q3Percent: 0,
      q4Percent: 0,
    ),
  );

  String _currentKeyword = '';
  String lastQuery = '';
  int _requestId = 0;
  int _journalPage = 1;
  int _totalJournalCount = 0;
  String? _resolvedTopicId;
  bool _isLoadingMore = false;
  final InFlightPageGuard _pageGuard = InFlightPageGuard();

  String get currentKeyword => _currentKeyword;

  bool get isGlobalView => _currentKeyword.isEmpty;

  bool get isLoadingMore => _isLoadingMore || _pageGuard.hasPageInFlight;

  bool get hasMoreJournals {
    final current = state.value;
    if (current == null || current.journals.isEmpty) return false;
    return current.journals.length < _totalJournalCount;
  }

  @override
  FutureOr<LeadingJournalsOverview> build() {
    return emptyOverview;
  }

  Future<void> fetch(String keyword, {bool forceRefresh = false}) async {
    final trimmed = keyword.trim();
    if (!forceRefresh &&
        _currentKeyword == trimmed &&
        state.hasValue &&
        !state.isLoading &&
        state.requireValue.journals.isNotEmpty) {
      return;
    }

    _currentKeyword = trimmed;
    lastQuery = trimmed;
    _journalPage = 1;
    _resolvedTopicId = null;
    _totalJournalCount = 0;
    _pageGuard.reset();
    final requestId = ++_requestId;

    state = const AsyncValue.loading();

    try {
      final overview = trimmed.isEmpty
          ? await _loadGlobal()
          : await _loadForKeyword(trimmed);

      if (requestId != _requestId) return;
      state = AsyncValue.data(overview);
    } catch (error, stackTrace) {
      if (requestId != _requestId) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> reload() => fetch(_currentKeyword, forceRefresh: true);

  Future<void> loadMore() async {
    if (_pageGuard.hasPageInFlight ||
        _isLoadingMore ||
        !hasMoreJournals) {
      return;
    }

    final current = state.value;
    if (current == null || state.isLoading) return;

    final nextPage = _journalPage + 1;
    if (!_pageGuard.tryAcquire(nextPage)) return;

    _isLoadingMore = true;
    final requestId = _requestId;

    state = AsyncValue.data(
      current.copyWith(journals: [...current.journals]),
    );

    try {
      final pageResult = _currentKeyword.isEmpty
          ? await _fetchGlobalLeaderboardPage(nextPage)
          : await _fetchTopicLeaderboardPage(nextPage);

      if (requestId != _requestId) return;

      final mergedJournals = _mergeJournals(current.journals, pageResult.journals);
      _journalPage = nextPage;
      _totalJournalCount = pageResult.totalCount;

      state = AsyncValue.data(
        current.copyWith(journals: mergedJournals),
      );
    } catch (_) {
      // Keep current data on pagination errors.
    } finally {
      if (requestId == _requestId) {
        _pageGuard.release(nextPage);
        _isLoadingMore = false;
        final latest = state.value;
        if (latest != null) {
          state = AsyncValue.data(
            latest.copyWith(journals: [...latest.journals]),
          );
        }
      }
    }
  }

  Future<LeadingJournalsLeaderboardPage> _fetchGlobalLeaderboardPage(
    int page,
  ) async {
    final result = await ref.read(leadingJournalRepositoryProvider).getLeaderboardPage(
          page: page,
          perPage: _pageSize,
        );

    return result.fold(
      (failure) => throw failure,
      (page) => page,
    );
  }

  Future<LeadingJournalsLeaderboardPage> _fetchTopicLeaderboardPage(
    int page,
  ) async {
    final result = await ref.read(getTopJournalsUseCaseProvider)(
      GetTopJournalsParams(
        keyword: _currentKeyword,
        limit: _pageSize,
        page: page,
        topicId: _resolvedTopicId,
      ),
    );

    return result.fold(
      (failure) => throw failure,
      (page) {
        _resolvedTopicId ??= page.topicId;
        return LeadingJournalsLeaderboardPage(
          journals: page.journals
              .map(
                (journal) => LeadingJournalEntity(
                  id: journal.id,
                  name: journal.displayName,
                  articleCount: journal.worksCount,
                  totalCitations: journal.citedByCount,
                  hIndex: journal.hIndex.toDouble(),
                ),
              )
              .toList(),
          totalCount: page.totalCount,
        );
      },
    );
  }

  Future<LeadingJournalsOverview> _loadGlobal() async {
    final result = await ref.read(getLeadingJournalsUseCaseProvider)();
    return result.fold(
      (failure) => throw failure,
      (overview) {
        _totalJournalCount = overview.insights.activeJournals;
        return overview;
      },
    );
  }

  Future<LeadingJournalsOverview> _loadForKeyword(String keyword) async {
    final result = await ref.read(getTopJournalsUseCaseProvider)(
      GetTopJournalsParams(keyword: keyword, limit: _pageSize, page: 1),
    );

    return result.fold(
      (failure) => throw failure,
      (page) {
        _resolvedTopicId = page.topicId;
        _totalJournalCount = page.totalCount;
        return _overviewFromTopicJournals(page);
      },
    );
  }

  LeadingJournalsOverview _overviewFromTopicJournals(TopJournalsPage page) {
    final journals = page.journals;
    if (journals.isEmpty) {
      throw const NotFoundFailure('No journals found for this keyword.');
    }

    final leading = journals
        .map(
          (journal) => LeadingJournalEntity(
            id: journal.id,
            name: journal.displayName,
            articleCount: journal.worksCount,
            totalCitations: journal.citedByCount,
            hIndex: journal.hIndex.toDouble(),
          ),
        )
        .toList();

    final prolific = leading.reduce(
      (current, next) =>
          next.articleCount > current.articleCount ? next : current,
    );
    final highestImpact = leading.reduce(
      (current, next) => next.hIndex > current.hIndex ? next : current,
    );
    final avgCitations = leading
            .map((journal) => journal.totalCitations)
            .reduce((a, b) => a + b) /
        leading.length;

    return LeadingJournalsOverview(
      journals: leading,
      insights: LeadingJournalInsights(
        activeJournals: page.totalCount,
        mostProlificJournal: prolific.name,
        mostProlificCount: prolific.articleCount,
        highestImpactJournal: highestImpact.name,
        highestImpactHIndex: highestImpact.hIndex,
        avgCitations: avgCitations,
      ),
      quartileDistribution: _quartileFromHIndex(leading),
    );
  }

  List<LeadingJournalEntity> _mergeJournals(
    List<LeadingJournalEntity> existing,
    List<LeadingJournalEntity> incoming,
  ) {
    final seen = existing.map((journal) => journal.id).toSet();
    final merged = List<LeadingJournalEntity>.from(existing);

    for (final journal in incoming) {
      if (seen.add(journal.id)) {
        merged.add(journal);
      }
    }

    return merged;
  }

  JournalQuartileDistribution _quartileFromHIndex(
    List<LeadingJournalEntity> journals,
  ) {
    if (journals.isEmpty) {
      return emptyOverview.quartileDistribution;
    }

    final hIndexes = journals.map((journal) => journal.hIndex).toList()..sort();
    final p25 = _percentile(hIndexes, 0.25);
    final p50 = _percentile(hIndexes, 0.50);
    final p75 = _percentile(hIndexes, 0.75);

    var q1 = 0;
    var q2 = 0;
    var q3 = 0;
    var q4 = 0;

    for (final journal in journals) {
      final value = journal.hIndex;
      if (value >= p75) {
        q1++;
      } else if (value >= p50) {
        q2++;
      } else if (value >= p25) {
        q3++;
      } else {
        q4++;
      }
    }

    final total = journals.length.toDouble();
    return JournalQuartileDistribution(
      q1Percent: q1 / total * 100,
      q2Percent: q2 / total * 100,
      q3Percent: q3 / total * 100,
      q4Percent: q4 / total * 100,
    );
  }

  double _percentile(List<double> sortedValues, double percentile) {
    if (sortedValues.isEmpty) return 0;
    final index = ((sortedValues.length - 1) * percentile).round();
    return sortedValues[index.clamp(0, sortedValues.length - 1)];
  }
}
