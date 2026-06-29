import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/keyword_entity.dart';
import 'package:synapse/domain/repositories/keyword_repository.dart';

class GetKeywordByIdParams {
  final String id;

  const GetKeywordByIdParams({required this.id});
}

class GetKeywordByIdUseCase
    implements ParamUseCase<KeywordEntity, GetKeywordByIdParams> {
  final KeywordRepository _repository;

  GetKeywordByIdUseCase(this._repository);

  @override
  Future<Either<Failure, KeywordEntity>> call(GetKeywordByIdParams params) {
    return _repository.getKeywordById(params.id);
  }
}
