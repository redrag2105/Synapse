import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/keyword_entity.dart';
import 'package:synapse/domain/repositories/keyword_repository.dart';

class GetTrendingKeywordsParams {
  final int limit;

  const GetTrendingKeywordsParams({this.limit = 6});
}

class GetTrendingKeywordsUseCase
    implements ParamUseCase<List<KeywordEntity>, GetTrendingKeywordsParams> {
  final KeywordRepository _repository;

  GetTrendingKeywordsUseCase(this._repository);

  @override
  Future<Either<Failure, List<KeywordEntity>>> call(
    GetTrendingKeywordsParams params,
  ) {
    return _repository.getTrendingKeywords(limit: params.limit);
  }
}
