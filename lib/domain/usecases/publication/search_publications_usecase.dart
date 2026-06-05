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
    // Bước 1: Tìm Topic ID dựa trên từ khóa (chỉ cần lấy 1 kết quả chính xác nhất)
    final topicResult = await _topicRepository.searchTopics(
      params.keyword,
      limit: 1,
    );

    return topicResult.fold(
      (failure) async =>
          Left(failure), // Nếu lỗi (mất mạng, 429...), trả về lỗi luôn
      (topics) async {
        if (topics.isEmpty) {
          return const Left(
            NotFoundFailure(
              'Không tìm thấy chủ đề nghiên cứu nào khớp với từ khóa của bạn.',
            ),
          );
        }

        // Trích xuất mã ID (VD: "https://openalex.org/T12419" -> "T12419")
        final topicId = topics.first.id.split('/').last;

        // Bước 2: Dùng Topic ID để lấy danh sách bài báo
        return await _publicationRepository.getPublicationsByTopicId(
          topicId,
          page: params.page,
          limit: params.limit,
        );
      },
    );
  }
}
