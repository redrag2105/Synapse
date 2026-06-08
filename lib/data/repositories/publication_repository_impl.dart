import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/utils/error_handler.dart';
import 'package:synapse/app/utils/request_deduplicator.dart';
import 'package:synapse/data/models/publication_model.dart';
import 'package:synapse/data/providers/apis/api_publication.dart';
import 'package:synapse/domain/entities/publication_entity.dart';
import 'package:synapse/domain/entities/topic_entity.dart';
import 'package:synapse/domain/repositories/publication_repository.dart';

class PublicationRepositoryImpl
    with RequestDeduplicator
    implements PublicationRepository {
  final ApiPublication _apiPublication;

  PublicationRepositoryImpl(this._apiPublication);

  @override
  Future<Either<Failure, List<PublicationEntity>>> getPublicationsByTopicId(
    String topicId, {
    int page = 1,
    int limit = 25,
  }) async {
    return deduplicate(
      cacheKey: 'pubs_${topicId}_${page}_$limit',
      action: () async {
        try {
          final response = await _apiPublication.getWorks(
            filter: topicId.isNotEmpty ? 'topics.id:$topicId' : null,
            page: page,
            perPage: limit,
            sort: 'cited_by_count:desc',
            select:
                'id,title,display_name,doi,publication_year,publication_date,cited_by_count,primary_location,authorships,type,open_access',
          );

          final results = response['results'] as List;
          final publications = results
              .map((e) => PublicationModel.fromJson(e))
              .toList();

          return Right(publications);
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }

  @override
  Future<Either<Failure, Map<int, int>>> getPublicationTrendByTopicId(
    String? topicId,
  ) async {
    final cleanId = (topicId != null && topicId.isNotEmpty)
        ? topicId.split('/').last
        : 'global';

    return deduplicate(
      cacheKey: 'trend_$cleanId',
      action: () async {
        try {
          String? filter;
          if (topicId != null && topicId.isNotEmpty) {
            filter = 'topics.id:$cleanId';
          }

          final response = await _apiPublication.getWorks(
            filter: filter,
            groupBy: 'publication_year',
          );

          final groups = response['group_by'] as List;
          final Map<int, int> trendData = {};
          final currentYear = DateTime.now().year;

          for (var group in groups) {
            final yearStr = group['key'].toString();
            final year = int.tryParse(yearStr);
            final count = group['count'] as int;

            if (year != null && year >= 1950 && year <= currentYear) {
              trendData[year] = count;
            }
          }

          return Right(trendData);
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }

  @override
  Future<Either<Failure, PublicationEntity>> getPublicationById(
    String id,
  ) async {
    return deduplicate(
      cacheKey: 'pub_id_$id',
      action: () async {
        try {
          final response = await _apiPublication.getWorkById(id: id);
          final publication = PublicationModel.fromJson(response);
          return Right(publication);
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<TopicEntity>>> getTrendingTopics() async {
    return deduplicate(
      cacheKey: 'trending_topics_home',
      action: () async {
        try {
          final currentYear = DateTime.now().year;
          final filterYear = '${currentYear - 2}-$currentYear';

          final response = await _apiPublication.getWorks(
            filter: 'publication_year:$filterYear',
            groupBy: 'topics.id',
          );

          final groups = response['group_by'] as List;

          final topics = groups.take(6).map((e) {
            return TopicEntity(
              id: e['key'].toString(),
              displayName: e['key_display_name'].toString(),
              description: null,
              worksCount: e['count'] as int,
            );
          }).toList();

          return Right(topics);
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }
}
