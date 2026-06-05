import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/repositories/publication_repository.dart';
import 'package:synapse/domain/repositories/topic_repository.dart';

class GetPublicationTrendParams {
  final String? keyword;
  final String? topicId; // Hỗ trợ truyền thẳng ID nếu có

  GetPublicationTrendParams({this.keyword, this.topicId});
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
    String? finalTopicId = params.topicId;

    // Nếu KHÔNG có sẵn topicId, NHƯNG lại CÓ keyword -> Đi tìm Topic
    if (finalTopicId == null &&
        params.keyword != null &&
        params.keyword!.isNotEmpty) {
      final topicResult = await _topicRepository.searchTopics(
        params.keyword!,
        limit: 1,
      );

      // Phân tích kết quả tìm kiếm Topic
      final Either<Failure, String?> searchOutcome = topicResult.fold(
        (failure) => Left(failure),
        (topics) {
          if (topics.isEmpty) {
            return const Left(
              NotFoundFailure(
                'Không tìm thấy chủ đề nghiên cứu để phân tích xu hướng.',
              ),
            );
          }
          // Trích xuất ID
          return Right(topics.first.id.split('/').last);
        },
      );

      // Nếu tìm kiếm lỗi hoặc không ra kết quả -> Trả về lỗi luôn
      if (searchOutcome.isLeft()) {
        return Left(
          searchOutcome.getLeft().getOrElse(
            () => const ServerFailure('Lỗi không xác định'),
          ),
        );
      }

      // Gắn ID vừa tìm được vào finalTopicId
      finalTopicId = searchOutcome.getRight().toNullable();
    }

    // Cuối cùng, gọi Repository (Nếu finalTopicId là null, repo tự hiểu là lấy Global Trend)
    return await _publicationRepository.getPublicationTrendByTopicId(
      finalTopicId,
    );
  }
}
