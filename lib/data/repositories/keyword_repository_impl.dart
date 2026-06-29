import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/utils/error_handler.dart';
import 'package:synapse/app/utils/request_deduplicator.dart';
import 'package:synapse/data/models/keyword_model.dart';
import 'package:synapse/data/providers/apis/api_keyword.dart';
import 'package:synapse/data/providers/apis/api_publication.dart';
import 'package:synapse/domain/entities/keyword_entity.dart';
import 'package:synapse/domain/repositories/keyword_repository.dart';

class KeywordRepositoryImpl with RequestDeduplicator implements KeywordRepository {
  final ApiKeyword _apiKeyword;
  final ApiPublication _apiPublication;

  static const _keywordSelect = 'id,display_name,works_count,cited_by_count';

  KeywordRepositoryImpl(this._apiKeyword, this._apiPublication);

  @override
  Future<Either<Failure, KeywordEntity>> getKeywordById(String id) async {
    return deduplicate(
      cacheKey: 'keyword_id_$id',
      action: () async {
        try {
          final response = await _apiKeyword.getKeywordById(
            id: id,
            select: _keywordSelect,
          );
          return Right(KeywordModel.fromJson(response));
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<KeywordEntity>>> searchKeywords(
    String query, {
    int page = 1,
    int limit = 25,
  }) async {
    return deduplicate(
      cacheKey: 'search_keywords_${query}_${page}_$limit',
      action: () async {
        try {
          final response = await _apiKeyword.getKeywords(
            search: query,
            page: page,
            perPage: limit,
            select: _keywordSelect,
          );

          final results = response['results'] as List;
          final keywords =
              results.map((e) => KeywordModel.fromJson(e)).toList();

          return Right(keywords);
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<KeywordEntity>>> getMostFrequentKeywords({
    int limit = 10,
  }) async {
    return deduplicate(
      cacheKey: 'most_frequent_keywords_$limit',
      action: () async {
        try {
          final response = await _apiKeyword.getKeywords(
            sort: 'works_count:desc',
            perPage: limit,
            select: _keywordSelect,
          );

          final results = response['results'] as List;
          final keywords =
              results.map((e) => KeywordModel.fromJson(e)).toList();

          return Right(keywords);
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<KeywordEntity>>> getTrendingKeywords({
    int limit = 6,
  }) async {
    return deduplicate(
      cacheKey: 'trending_keywords_$limit',
      action: () async {
        try {
          final currentYear = DateTime.now().year;
          final filterYear = '${currentYear - 2}-$currentYear';

          final response = await _apiPublication.getWorks(
            filter: 'publication_year:$filterYear',
            groupBy: 'keywords.id',
            perPage: limit,
          );

          final groups = response['group_by'] as List;
          final keywords = groups
              .take(limit)
              .map((e) => KeywordModel.fromGroupByJson(e))
              .toList();

          return Right(keywords);
        } catch (e) {
          return Left(ErrorHandler.handle(e));
        }
      },
    );
  }
}
