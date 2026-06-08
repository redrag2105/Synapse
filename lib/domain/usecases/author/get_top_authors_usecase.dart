import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/author_entity.dart';
import 'package:synapse/domain/repositories/author_repository.dart';
import 'package:synapse/domain/repositories/topic_repository.dart';

class GetTopAuthorsParams {
  final String keyword;
  final int limit;
  GetTopAuthorsParams({required this.keyword, this.limit = 10});
}

class GetTopAuthorsUseCase
    implements ParamUseCase<List<AuthorEntity>, GetTopAuthorsParams> {
  final TopicRepository _topicRepository;
  final AuthorRepository _authorRepository;

  GetTopAuthorsUseCase(this._topicRepository, this._authorRepository);

  @override
  Future<Either<Failure, List<AuthorEntity>>> call(
    GetTopAuthorsParams params,
  ) async {
    if (params.keyword.isEmpty) {
      return await _authorRepository.getTopAuthorsByTopicId(
        '',
        limit: params.limit,
      );
    }

    final topicResult = await _topicRepository.searchTopics(
      params.keyword,
      limit: 1,
    );

    return topicResult.fold((failure) async => Left(failure), (topics) async {
      if (topics.isEmpty) {
        return const Left(NotFoundFailure('Không tìm thấy chủ đề.'));
      }

      final topicId = topics.first.id.split('/').last;
      return await _authorRepository.getTopAuthorsByTopicId(
        topicId,
        limit: params.limit,
      );
    });
  }
}
