import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/types/paginated_list_state.dart';
import 'package:synapse/domain/entities/top_journals_page.dart';
import 'package:synapse/domain/repositories/journal_repository.dart';
import 'package:synapse/domain/repositories/topic_repository.dart';

class GetTopJournalsParams {
  final String keyword;
  final int limit;
  final int page;
  final String? topicId;

  GetTopJournalsParams({
    required this.keyword,
    this.limit = PaginatedListState.defaultPageSize,
    this.page = 1,
    this.topicId,
  });
}

class GetTopJournalsUseCase
    implements ParamUseCase<TopJournalsPage, GetTopJournalsParams> {
  final TopicRepository _topicRepository;
  final JournalRepository _journalRepository;

  GetTopJournalsUseCase(this._topicRepository, this._journalRepository);

  @override
  Future<Either<Failure, TopJournalsPage>> call(
    GetTopJournalsParams params,
  ) async {
    if (params.keyword.isEmpty) {
      return await _journalRepository.getTopJournalsByTopicId(
        '',
        limit: params.limit,
        page: params.page,
      );
    }

    if (params.topicId != null && params.topicId!.isNotEmpty) {
      return await _journalRepository.getTopJournalsByTopicId(
        params.topicId!,
        limit: params.limit,
        page: params.page,
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
      final pageResult = await _journalRepository.getTopJournalsByTopicId(
        topicId,
        limit: params.limit,
        page: params.page,
      );

      return pageResult.map(
        (page) => TopJournalsPage(
          journals: page.journals,
          totalCount: page.totalCount,
          topicId: topicId,
        ),
      );
    });
  }
}
