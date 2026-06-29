import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/keyword_entity.dart';

abstract class KeywordRepository {
  Future<Either<Failure, KeywordEntity>> getKeywordById(String id);

  Future<Either<Failure, List<KeywordEntity>>> searchKeywords(
    String query, {
    int page = 1,
    int limit = 25,
  });

  Future<Either<Failure, List<KeywordEntity>>> getMostFrequentKeywords({
    int limit = 10,
  });

  Future<Either<Failure, List<KeywordEntity>>> getTrendingKeywords({
    int limit = 6,
  });
}
