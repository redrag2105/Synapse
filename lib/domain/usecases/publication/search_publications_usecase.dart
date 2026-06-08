import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/publication_entity.dart';
import 'package:synapse/domain/repositories/publication_repository.dart';
import 'package:synapse/domain/repositories/topic_repository.dart';

class SearchPublicationsParams {
  final String keyword;
  final int page;
  final int limit;

  SearchPublicationsParams({
    required this.keyword,
    this.page = 1,
    this.limit = 25,
  });
}

class SearchPublicationsUseCase
    implements ParamUseCase<List<PublicationEntity>, SearchPublicationsParams> {
  final TopicRepository _topicRepository;
  final PublicationRepository _publicationRepository;

  SearchPublicationsUseCase(this._topicRepository, this._publicationRepository);

  @override
  Future<Either<Failure, List<PublicationEntity>>> call(
    SearchPublicationsParams params,
  ) async {
    if (params.keyword.isEmpty) {
      return await _publicationRepository.getPublicationsByTopicId(
        '',
        page: params.page,
        limit: params.limit,
      );
    }

    final topicResult = await _topicRepository.searchTopics(
      params.keyword,
      limit: 1,
    );

    return topicResult.fold((failure) async => Left(failure), (topics) async {
      if (topics.isEmpty) {
        return const Right([]);
      }

      final topicId = topics.first.id.split('/').last;

      return await _publicationRepository.getPublicationsByTopicId(
        topicId,
        page: params.page,
        limit: params.limit,
      );
    });
  }
}
