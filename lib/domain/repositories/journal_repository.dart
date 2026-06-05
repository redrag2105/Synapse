import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/journal_entity.dart';

abstract class JournalRepository {
  Future<Either<Failure, List<JournalEntity>>> getTopJournalsByTopicId(
    String topicId, {
    int limit = 10,
  });
}
