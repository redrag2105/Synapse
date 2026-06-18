import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/utils/error_handler.dart';
import 'package:synapse/app/utils/request_deduplicator.dart';
import 'package:synapse/data/models/leading_journal_model.dart';
import 'package:synapse/data/providers/apis/api_journal.dart';
import 'package:synapse/domain/entities/leading_journal_entity.dart';
import 'package:synapse/domain/repositories/leading_journal_repository.dart';

class LeadingJournalRepositoryImpl
    with RequestDeduplicator
    implements LeadingJournalRepository {
  static const String _journalFilter = 'type:journal';
  static const String _selectFields =
      'id,display_name,works_count,cited_by_count,summary_stats';
  static const int _leaderboardSize = 25;
  static const int _quartileReferenceSize = 100;

  final ApiJournal _apiJournal;

  LeadingJournalRepositoryImpl(this._apiJournal);

  @override
  Future<Either<Failure, LeadingJournalsOverview>> getLeadingJournals() async {
    return deduplicate(
      cacheKey: 'leading_journals_overview',
      action: () async {
        try {
          final leaderboardResponse = await _apiJournal.getJournals(
            filter: _journalFilter,
            sort: 'summary_stats.h_index:desc',
            perPage: _quartileReferenceSize,
            select: _selectFields,
          );

          final prolificResponse = await _apiJournal.getJournals(
            filter: _journalFilter,
            sort: 'works_count:desc',
            perPage: 1,
            select: _selectFields,
          );

          final referenceJournals = _parseResults(leaderboardResponse);
          if (referenceJournals.isEmpty) {
            return const Left(
              NotFoundFailure('Không tìm thấy dữ liệu tạp chí từ OpenAlex.'),
            );
          }

          final leaderboard =
              List<LeadingJournalEntity>.from(
                referenceJournals.take(_leaderboardSize),
              );
          final prolificList = _parseResults(prolificResponse);
          final prolific = prolificList.isNotEmpty
              ? prolificList.first
              : leaderboard.first;

          final activeJournals =
              leaderboardResponse['meta']?['count'] as int? ??
              referenceJournals.length;

          final insights = _buildInsights(
            leaderboard: leaderboard,
            prolific: prolific,
            activeJournals: activeJournals,
          );

          final quartileDistribution = _buildQuartileDistribution(
            portfolio: leaderboard,
            referenceSample: referenceJournals,
          );

          return Right(
            LeadingJournalsOverview(
              journals: leaderboard,
              insights: insights,
              quartileDistribution: quartileDistribution,
            ),
          );
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }

  List<LeadingJournalEntity> _parseResults(Map<String, dynamic> response) {
    final results = response['results'] as List? ?? [];
    return results
        .whereType<Map<String, dynamic>>()
        .map(LeadingJournalModel.fromOpenAlexJson)
        .map(
          (model) => LeadingJournalEntity(
            id: model.id,
            name: model.name,
            articleCount: model.articleCount,
            totalCitations: model.totalCitations,
            hIndex: model.hIndex,
            twoYearMeanCitedness: model.twoYearMeanCitedness,
          ),
        )
        .toList();
  }

  LeadingJournalInsights _buildInsights({
    required List<LeadingJournalEntity> leaderboard,
    required LeadingJournalEntity prolific,
    required int activeJournals,
  }) {
    LeadingJournalEntity highestImpact = leaderboard.first;
    for (var i = 1; i < leaderboard.length; i++) {
      if (leaderboard[i].hIndex > highestImpact.hIndex) {
        highestImpact = leaderboard[i];
      }
    }
    final avgCitations = leaderboard.isEmpty
        ? 0.0
        : leaderboard.map((j) => j.totalCitations).reduce((a, b) => a + b) /
            leaderboard.length;

    return LeadingJournalInsights(
      activeJournals: activeJournals,
      mostProlificJournal: prolific.name,
      mostProlificCount: prolific.articleCount,
      highestImpactJournal: highestImpact.name,
      highestImpactHIndex: highestImpact.hIndex,
      avgCitations: avgCitations,
    );
  }

  /// Buckets the leaderboard portfolio into Q1–Q4 using 2yr mean citedness
  /// percentiles from a larger OpenAlex reference sample.
  JournalQuartileDistribution _buildQuartileDistribution({
    required List<LeadingJournalEntity> portfolio,
    required List<LeadingJournalEntity> referenceSample,
  }) {
    if (portfolio.isEmpty) {
      return const JournalQuartileDistribution(
        q1Percent: 0,
        q2Percent: 0,
        q3Percent: 0,
        q4Percent: 0,
      );
    }

    final citednessValues = referenceSample
        .map((journal) => journal.twoYearMeanCitedness)
        .toList()
      ..sort();

    final p25 = _percentile(citednessValues, 0.25);
    final p50 = _percentile(citednessValues, 0.50);
    final p75 = _percentile(citednessValues, 0.75);

    var q1 = 0;
    var q2 = 0;
    var q3 = 0;
    var q4 = 0;

    for (final journal in portfolio) {
      final value = journal.twoYearMeanCitedness;
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

    final total = portfolio.length.toDouble();
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
