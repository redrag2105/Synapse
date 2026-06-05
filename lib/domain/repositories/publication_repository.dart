import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/publication_entity.dart';
import 'package:synapse/domain/entities/topic_entity.dart';

abstract class PublicationRepository {
  Future<Either<Failure, List<PublicationEntity>>> getPublicationsByTopicId(
    String topicId, {
    int page = 1,
    int limit = 25,
  });

  Future<Either<Failure, Map<int, int>>> getPublicationTrendByTopicId(
    String? topicId,
  );

  Future<Either<Failure, PublicationEntity>> getPublicationById(String id);

  Future<Either<Failure, List<TopicEntity>>> getTrendingTopics();
}
