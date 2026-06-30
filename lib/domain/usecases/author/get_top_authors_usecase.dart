import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/types/paged_result.dart';
import 'package:synapse/app/types/paginated_list_state.dart';
import 'package:synapse/domain/entities/author_entity.dart';
import 'package:synapse/domain/repositories/author_repository.dart';
import 'package:synapse/domain/repositories/topic_repository.dart';

class GetTopAuthorsParams {
  final String keyword;
  final int limit;
  final int page;
  final String? topicId;

  GetTopAuthorsParams({
    required this.keyword,
    this.limit = PaginatedListState.defaultPageSize,
    this.page = 1,
    this.topicId,
  });
}

class GetTopAuthorsUseCase
    implements ParamUseCase<PagedResult<AuthorEntity>, GetTopAuthorsParams> {
  final TopicRepository _topicRepository;
  final AuthorRepository _authorRepository;

  GetTopAuthorsUseCase(this._topicRepository, this._authorRepository);

  @override
  Future<Either<Failure, PagedResult<AuthorEntity>>> call(
    GetTopAuthorsParams params,
  ) async {
    if (params.keyword.isEmpty) {
      return _authorRepository.getTopAuthorsByKeyword(
        '',
        page: params.page,
        limit: params.limit,
      );
    }

    if (params.topicId != null && params.topicId!.isNotEmpty) {
      final result = await _authorRepository.getTopAuthorsByKeyword(
        params.keyword,
        page: params.page,
        limit: params.limit,
        topicId: params.topicId,
      );

      return result.map(
        (page) => PagedResult(
          items: page.items,
          hasMore: page.hasMore,
          totalCount: page.totalCount,
          topicId: params.topicId,
        ),
      );
    }

    final topicResult = await _topicRepository.searchTopics(
      params.keyword,
      limit: 1,
    );

    return topicResult.fold((failure) async => Left(failure), (topics) async {
      if (topics.isEmpty) {
        return _authorRepository.getTopAuthorsByKeyword(
          params.keyword,
          page: params.page,
          limit: params.limit,
        );
      }

      final topicId = topics.first.id.split('/').last;
      final pageResult = await _authorRepository.getTopAuthorsByKeyword(
        params.keyword,
        page: params.page,
        limit: params.limit,
        topicId: topicId,
      );

      return pageResult.map(
        (page) => PagedResult(
          items: page.items,
          hasMore: page.hasMore,
          totalCount: page.totalCount,
          topicId: topicId,
        ),
      );
    });
  }
}
