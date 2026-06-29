import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/top_journals_page.dart';
import 'package:synapse/domain/repositories/journal_repository.dart';
import 'package:synapse/domain/repositories/topic_repository.dart';

class GetTopJournalsParams {
  final String keyword;
  final int limit;
  GetTopJournalsParams({required this.keyword, this.limit = 10});
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
      return await _journalRepository.getTopJournalsByTopicId(
        topicId,
        limit: params.limit,
      );
    });
  }
}
