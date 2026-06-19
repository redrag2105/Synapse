import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/utils/error_handler.dart';
import 'package:synapse/app/utils/request_deduplicator.dart';
import 'package:synapse/data/models/journal_model.dart';
import 'package:synapse/data/providers/apis/api_journal.dart';
import 'package:synapse/domain/entities/journal_entity.dart';
import 'package:synapse/domain/repositories/journal_repository.dart';

class JournalRepositoryImpl
    with RequestDeduplicator
    implements JournalRepository {
  final ApiJournal _apiJournal;

  JournalRepositoryImpl(this._apiJournal);

  @override
  Future<Either<Failure, List<JournalEntity>>> getTopJournalsByTopicId(
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

          return Right(journals);
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }
}
