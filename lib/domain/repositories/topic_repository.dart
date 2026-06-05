import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/topic_entity.dart';

abstract class TopicRepository {
  Future<Either<Failure, List<TopicEntity>>> searchTopics(
    String keyword, {
    int page = 1,
    int limit = 25,
  });

  Future<Either<Failure, TopicEntity>> getTopicById(String id);

  Future<Either<Failure, List<TopicEntity>>> getTopicHints(String keyword);
}
