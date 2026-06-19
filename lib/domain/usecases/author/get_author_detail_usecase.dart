import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/author_detail_entity.dart';
import 'package:synapse/domain/repositories/author_repository.dart';

class GetAuthorDetailParams {
  final String authorId;
  final String keyword;
  final int worksLimit;

  GetAuthorDetailParams({
    required this.authorId,
    required this.keyword,
    this.worksLimit = 25,
  });
}

class GetAuthorDetailUseCase
    implements ParamUseCase<AuthorDetailEntity, GetAuthorDetailParams> {
  final AuthorRepository _authorRepository;

  GetAuthorDetailUseCase(this._authorRepository);

  @override
  Future<Either<Failure, AuthorDetailEntity>> call(
    GetAuthorDetailParams params,
  ) async {
    final profileResult = await _authorRepository.getAuthorById(params.authorId);

    return await profileResult.fold(
      (failure) async => Left(failure),
      (profile) async {
        final worksResult = await _authorRepository.getAuthorWorksByTopic(
          params.authorId,
          params.keyword,
          limit: params.worksLimit,
        );

        return worksResult.map(
          (works) => AuthorDetailEntity(profile: profile, topicWorks: works),
        );
      },
    );
  }
}
