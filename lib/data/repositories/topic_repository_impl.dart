import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/utils/error_handler.dart';
import 'package:synapse/app/utils/request_deduplicator.dart';
import 'package:synapse/data/models/topic_model.dart';
import 'package:synapse/data/providers/apis/api_topic.dart';
import 'package:synapse/domain/entities/topic_entity.dart';
import 'package:synapse/domain/repositories/topic_repository.dart';

class TopicRepositoryImpl with RequestDeduplicator implements TopicRepository {
  final ApiTopic _apiTopic;

  TopicRepositoryImpl(this._apiTopic);

  @override
  Future<Either<Failure, List<TopicEntity>>> searchTopics(
    String keyword, {
    int page = 1,
    int limit = 25,
  }) async {
    return deduplicate(
      cacheKey: 'search_topics_${keyword}_${page}_$limit',
      action: () async {
        try {
          final response = await _apiTopic.getTopics(
            search: keyword,
            page: page,
            perPage: limit,
            select: 'id,display_name,description,keywords,works_count',
          );

          final results = response['results'] as List;
          final topics = results.map((e) => TopicModel.fromJson(e)).toList();

          return Right(topics);
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }

  @override
  Future<Either<Failure, TopicEntity>> getTopicById(String id) async {
    return deduplicate(
      cacheKey: 'topic_id_$id',
      action: () async {
        try {
          final response = await _apiTopic.getTopicById(
            id: id,
            select: 'id,display_name,description,keywords,works_count',
          );
          return Right(TopicModel.fromJson(response));
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<TopicEntity>>> getTopicHints(
    String keyword,
  ) async {
    return deduplicate(
      cacheKey: 'topic_hints_$keyword',
      action: () async {
        try {
          final response = await _apiTopic.autocompleteTopics(query: keyword);
          final results = response['results'] as List;

          final topics = results.map((e) {
            e['description'] = e['hint'] ?? '';
            return TopicModel.fromJson(e);
          }).toList();

          return Right(topics);
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }
}
