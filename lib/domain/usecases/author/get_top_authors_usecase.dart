import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/types/paged_result.dart';
import 'package:synapse/app/types/paginated_list_state.dart';
import 'package:synapse/domain/entities/author_entity.dart';
import 'package:synapse/domain/repositories/author_repository.dart';

class GetTopAuthorsParams {
  final String keyword;
  final int limit;

  GetTopAuthorsParams({
    required this.keyword,
    this.limit = PaginatedListState.defaultPageSize,
  });
}

class GetTopAuthorsUseCase
    implements ParamUseCase<PagedResult<AuthorEntity>, GetTopAuthorsParams> {
  final AuthorRepository _authorRepository;

  GetTopAuthorsUseCase(this._authorRepository);

  @override
  Future<Either<Failure, PagedResult<AuthorEntity>>> call(
    GetTopAuthorsParams params,
  ) async {
    return _authorRepository.getTopAuthorsByKeyword(
      params.keyword,
      limit: params.limit,
    );
  }
}
