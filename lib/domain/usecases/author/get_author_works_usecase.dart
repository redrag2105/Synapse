import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/types/paginated_list_state.dart';
import 'package:synapse/domain/entities/author_entity.dart';
import 'package:synapse/domain/entities/publication_entity.dart';
import 'package:synapse/domain/repositories/author_repository.dart';

class GetAuthorWorksParams {
  final String authorId;
  final String keyword;
  final int page;
  final int limit;

  GetAuthorWorksParams({
    required this.authorId,
    required this.keyword,
    this.page = 1,
    this.limit = PaginatedListState.defaultPageSize,
  });
}

class GetAuthorWorksUseCase
    implements ParamUseCase<List<PublicationEntity>, GetAuthorWorksParams> {
  final AuthorRepository _authorRepository;

  GetAuthorWorksUseCase(this._authorRepository);

  @override
  Future<Either<Failure, List<PublicationEntity>>> call(
    GetAuthorWorksParams params,
  ) async {
    return _authorRepository.getAuthorWorksByTopic(
      params.authorId,
      params.keyword,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetAuthorProfileParams {
  final String authorId;

  GetAuthorProfileParams({required this.authorId});
}

class GetAuthorProfileUseCase
    implements ParamUseCase<AuthorEntity, GetAuthorProfileParams> {
  final AuthorRepository _authorRepository;

  GetAuthorProfileUseCase(this._authorRepository);

  @override
  Future<Either<Failure, AuthorEntity>> call(GetAuthorProfileParams params) {
    return _authorRepository.getAuthorById(params.authorId);
  }
}
