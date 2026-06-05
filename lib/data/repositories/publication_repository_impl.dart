import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/utils/error_handler.dart';
import 'package:synapse/data/models/publication_model.dart';
import 'package:synapse/data/providers/apis/api_publication.dart';
import 'package:synapse/domain/entities/publication_entity.dart';
import 'package:synapse/domain/repositories/publication_repository.dart';

class PublicationRepositoryImpl implements PublicationRepository {
  final ApiPublication _apiPublication;

  PublicationRepositoryImpl(this._apiPublication);

  @override
  Future<Either<Failure, List<PublicationEntity>>> getPublicationsByTopicId(
    String topicId, {
    int page = 1,
    int limit = 25,
  }) async {
    try {
      final response = await _apiPublication.getWorks(
        filter: 'topics.id:$topicId',
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
  }

  @override
  Future<Either<Failure, Map<int, int>>> getPublicationTrendByTopicId(
    String topicId,
  ) async {
    try {
      final response = await _apiPublication.getWorks(
        filter: 'topics.id:$topicId',
        groupBy: 'publication_year',
      );

      final groups = response['group_by'] as List;
      final Map<int, int> trendData = {};

      for (var group in groups) {
        final keyStr = group['key'].toString();
        final count = group['count'] as int;
        final year = int.tryParse(keyStr);

        if (year != null && year > 1900 && year <= DateTime.now().year + 1) {
          trendData[year] = count;
        }
      }

      return Right(trendData);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, PublicationEntity>> getPublicationById(
    String id,
  ) async {
    try {
      final response = await _apiPublication.getWorkById(id: id);

      final publication = PublicationModel.fromJson(response);
      return Right(publication);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
