import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/keyword_entity.dart';
import 'package:synapse/domain/repositories/keyword_repository.dart';

class GetMostFrequentKeywordsParams {
  final int limit;

  const GetMostFrequentKeywordsParams({this.limit = 10});
}

class GetMostFrequentKeywordsUseCase
    implements ParamUseCase<List<KeywordEntity>, GetMostFrequentKeywordsParams> {
  final KeywordRepository _repository;

  GetMostFrequentKeywordsUseCase(this._repository);

  @override
  Future<Either<Failure, List<KeywordEntity>>> call(
    GetMostFrequentKeywordsParams params,
  ) async {
    return _repository.getMostFrequentKeywords(limit: params.limit);
  }
}
