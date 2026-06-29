import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/top_journals_page.dart';
import 'package:synapse/domain/entities/leading_journal_entity.dart';
import 'package:synapse/domain/usecases/journal/get_top_journals_usecase.dart';

final leadingJournalsControllerProvider = AsyncNotifierProvider<
    LeadingJournalsController, LeadingJournalsOverview>(
  LeadingJournalsController.new,
);

class LeadingJournalsController extends AsyncNotifier<LeadingJournalsOverview> {
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

  String get currentKeyword => _currentKeyword;

  bool get isGlobalView => _currentKeyword.isEmpty;

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

  Future<LeadingJournalsOverview> _loadGlobal() async {
    final result = await ref.read(getLeadingJournalsUseCaseProvider)();
    return result.fold(
      (failure) => throw failure,
      (overview) => overview,
    );
  }

  Future<LeadingJournalsOverview> _loadForKeyword(String keyword) async {
    final result = await ref.read(getTopJournalsUseCaseProvider)(
      GetTopJournalsParams(keyword: keyword, limit: 25),
    );

    return result.fold(
      (failure) => throw failure,
      (page) => _overviewFromTopicJournals(page),
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
