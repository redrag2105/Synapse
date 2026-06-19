import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/author_topic_matrix_entity.dart';
import 'package:synapse/domain/repositories/author_repository.dart';

class GetAuthorTopicMatrixParams {
  final List<String> authorIds;
  final int maxAuthors;
  final int maxTopics;

  GetAuthorTopicMatrixParams({
    required this.authorIds,
    this.maxAuthors = 5,
    this.maxTopics = 5,
  });
}

class GetAuthorTopicMatrixUseCase
    implements
        ParamUseCase<AuthorTopicMatrix, GetAuthorTopicMatrixParams> {
  final AuthorRepository _authorRepository;

  GetAuthorTopicMatrixUseCase(this._authorRepository);

  @override
  Future<Either<Failure, AuthorTopicMatrix>> call(
    GetAuthorTopicMatrixParams params,
  ) {
    return _authorRepository.getAuthorTopicMatrix(
      params.authorIds,
      maxAuthors: params.maxAuthors,
      maxTopics: params.maxTopics,
    );
  }
}
