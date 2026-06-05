import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/repositories/publication_repository.dart';
import 'package:synapse/domain/repositories/topic_repository.dart';

class GetPublicationTrendParams {
  final String keyword;
  GetPublicationTrendParams({required this.keyword});
}

class GetPublicationTrendUseCase
    implements ParamUseCase<Map<int, int>, GetPublicationTrendParams> {
  final TopicRepository _topicRepository;
  final PublicationRepository _publicationRepository;

  GetPublicationTrendUseCase(
    this._topicRepository,
    this._publicationRepository,
  );

  @override
  Future<Either<Failure, Map<int, int>>> call(
    GetPublicationTrendParams params,
  ) async {
    final topicResult = await _topicRepository.searchTopics(
      params.keyword,
      limit: 1,
    );

    return topicResult.fold((failure) async => Left(failure), (topics) async {
      if (topics.isEmpty) {
        return const Left(
          NotFoundFailure(
            'Không tìm thấy chủ đề nghiên cứu để phân tích xu hướng.',
          ),
        );
      }

      final topicId = topics.first.id.split('/').last;
      return await _publicationRepository.getPublicationTrendByTopicId(topicId);
    });
  }
}
