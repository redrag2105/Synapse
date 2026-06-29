import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/journal_detail_entity.dart';
import 'package:synapse/domain/entities/top_journals_page.dart';

abstract class JournalRepository {
  Future<Either<Failure, JournalDetailEntity>> getJournalById(String journalId);

  Future<Either<Failure, TopJournalsPage>> getTopJournalsByTopicId(
    String topicId, {
    int limit = 10,
  });
}
