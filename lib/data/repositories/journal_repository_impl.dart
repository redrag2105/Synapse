import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/utils/error_handler.dart';
import 'package:synapse/app/utils/request_deduplicator.dart';
import 'package:synapse/data/models/journal_model.dart';
import 'package:synapse/data/providers/apis/api_journal.dart';
import 'package:synapse/domain/entities/top_journals_page.dart';
import 'package:synapse/domain/repositories/journal_repository.dart';

class JournalRepositoryImpl
    with RequestDeduplicator
    implements JournalRepository {
  final ApiJournal _apiJournal;

  JournalRepositoryImpl(this._apiJournal);

  @override
  Future<Either<Failure, TopJournalsPage>> getTopJournalsByTopicId(
    String topicId, {
    int limit = 10,
  }) async {
    return deduplicate(
      cacheKey: 'top_journals_${topicId}_$limit',
      action: () async {
        try {
          final response = await _apiJournal.getJournals(
            filter: topicId.isNotEmpty ? 'topics.id:$topicId' : null,
            sort: 'works_count:desc',
            perPage: limit,
            select: 'id,display_name,works_count,cited_by_count,summary_stats',
          );

          final results = response['results'] as List;
          final journals = results
              .map((e) => JournalModel.fromJson(e))
              .toList();
          final totalCount =
              response['meta']?['count'] as int? ?? journals.length;

          return Right(
            TopJournalsPage(
              journals: journals,
              totalCount: totalCount,
            ),
          );
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }
}
