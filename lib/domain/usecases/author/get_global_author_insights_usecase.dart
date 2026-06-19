import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/global_author_insights_entity.dart';
import 'package:synapse/domain/repositories/author_repository.dart';

class GetGlobalAuthorInsightsParams {
  final String keyword;

  const GetGlobalAuthorInsightsParams({this.keyword = ''});
}

class GetGlobalAuthorInsightsUseCase
    implements
        ParamUseCase<GlobalAuthorInsights, GetGlobalAuthorInsightsParams> {
  final AuthorRepository _authorRepository;

  GetGlobalAuthorInsightsUseCase(this._authorRepository);

  @override
  Future<Either<Failure, GlobalAuthorInsights>> call(
    GetGlobalAuthorInsightsParams params,
  ) {
    return _authorRepository.getGlobalAuthorInsights(
      keyword: params.keyword,
    );
  }
}
