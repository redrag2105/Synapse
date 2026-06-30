import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/types/paginated_list_state.dart';
import 'package:synapse/domain/entities/author_entity.dart';
import 'package:synapse/domain/entities/author_topic_matrix_entity.dart';
import 'package:synapse/domain/entities/global_author_insights_entity.dart';
import 'package:synapse/domain/usecases/author/get_author_topic_matrix_usecase.dart';
import 'package:synapse/domain/usecases/author/get_global_author_insights_usecase.dart';
import 'package:synapse/domain/usecases/author/get_top_authors_usecase.dart';
import 'package:synapse/presentation/widgets/pagination_footer.dart';

typedef TopAuthorsListState = PaginatedListState<AuthorEntity>;

class TopAuthorsViewState {
  final TopAuthorsListState authors;
  final AuthorTopicMatrix? topicMatrix;
  final GlobalAuthorInsights? globalInsights;
  final bool isLoadingMatrix;
  final bool isLoadingInsights;

  const TopAuthorsViewState({
    this.authors = const TopAuthorsListState(),
    this.topicMatrix,
    this.globalInsights,
    this.isLoadingMatrix = false,
    this.isLoadingInsights = false,
  });

  TopAuthorsViewState copyWith({
    TopAuthorsListState? authors,
    AuthorTopicMatrix? topicMatrix,
    GlobalAuthorInsights? globalInsights,
    bool? isLoadingMatrix,
    bool? isLoadingInsights,
    bool clearMatrix = false,
    bool clearInsights = false,
  }) {
    return TopAuthorsViewState(
      authors: authors ?? this.authors,
      topicMatrix: clearMatrix ? null : (topicMatrix ?? this.topicMatrix),
      globalInsights: clearInsights
          ? null
          : (globalInsights ?? this.globalInsights),
      isLoadingMatrix: isLoadingMatrix ?? this.isLoadingMatrix,
      isLoadingInsights: isLoadingInsights ?? this.isLoadingInsights,
    );
  }
}

final topAuthorsControllerProvider =
    AsyncNotifierProvider<TopAuthorsController, TopAuthorsViewState>(
      TopAuthorsController.new,
    );

class TopAuthorsController extends AsyncNotifier<TopAuthorsViewState> {
  static const int _pageSize = PaginatedListState.defaultPageSize;

  String _currentKeyword = '';
  String lastQuery = '';
  int _requestId = 0;
  int _matrixRequestId = 0;
  int _currentPage = 1;
  String? _resolvedTopicId;
  final InFlightPageGuard _pageGuard = InFlightPageGuard();

  String get currentKeyword => _currentKeyword;

  bool get isGlobalView => _currentKeyword.isEmpty;

  bool get isLoadingMore =>
      (state.value?.authors.isLoadingMore ?? false) ||
      _pageGuard.hasPageInFlight;

  @override
  FutureOr<TopAuthorsViewState> build() {
    return const TopAuthorsViewState();
  }

  Future<void> fetchTopAuthors(
    String keyword, {
    bool saveHistory = true,
    int? limit,
    bool forceRefresh = false,
  }) async {
    final trimmed = keyword.trim();
    final isGlobal = trimmed.isEmpty;
    final pageSize = limit ?? _pageSize;

    if (!forceRefresh && _currentKeyword == trimmed) {
      if (state.isLoading ||
          (state.hasValue &&
              (state.value!.authors.items.isNotEmpty ||
                  state.value!.isLoadingMatrix ||
                  state.value!.isLoadingInsights))) {
        return;
      }
    }

    _currentKeyword = trimmed;
    _currentPage = 1;
    _resolvedTopicId = null;
    _pageGuard.reset();

    if (saveHistory) {
      lastQuery = isGlobal ? '' : trimmed;
    }

    final requestId = ++_requestId;

    Future<Either<Failure, GlobalAuthorInsights>>? insightsFuture;
    if (limit == null) {
      insightsFuture = ref.read(getGlobalAuthorInsightsUseCaseProvider)(
        GetGlobalAuthorInsightsParams(keyword: _currentKeyword),
      );
    }

    state = const AsyncValue.loading();

    final result = await ref.read(getTopAuthorsUseCaseProvider)(
      GetTopAuthorsParams(
        keyword: _currentKeyword,
        limit: pageSize,
        page: 1,
      ),
    );

    if (requestId != _requestId) return;

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (paged) {
        _resolvedTopicId = paged.topicId;

        state = AsyncValue.data(
          TopAuthorsViewState(
            authors: TopAuthorsListState(
              items: paged.items,
              currentPage: 1,
              hasMore: limit == null && paged.hasMore,
            ),
            isLoadingInsights: limit == null,
            isLoadingMatrix: limit == null && isGlobal && paged.items.isNotEmpty,
          ),
        );

        if (limit == null) {
          if (insightsFuture != null) {
            insightsFuture.then((insightsResult) {
              if (requestId != _requestId) return;
              final latest = state.value;
              if (latest == null) return;

              insightsResult.fold(
                (failure) => state = AsyncValue.data(
                  latest.copyWith(isLoadingInsights: false),
                ),
                (insights) => state = AsyncValue.data(
                  latest.copyWith(
                    globalInsights: insights,
                    isLoadingInsights: false,
                  ),
                ),
              );
            });
          }

          if (isGlobal && paged.items.isNotEmpty) {
            unawaited(_loadTopicMatrix(paged.items));
          }
        }
      },
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    final authorsState = current?.authors;
    if (current == null ||
        authorsState == null ||
        !authorsState.hasMore ||
        authorsState.isLoadingMore ||
        _pageGuard.hasPageInFlight ||
        state.isLoading) {
      return;
    }

    final nextPage = _currentPage + 1;
    if (!_pageGuard.tryAcquire(nextPage)) return;

    state = AsyncValue.data(
      current.copyWith(authors: authorsState.copyWith(isLoadingMore: true)),
    );

    final requestId = _requestId;

    try {
      final result = await ref.read(getTopAuthorsUseCaseProvider)(
        GetTopAuthorsParams(
          keyword: _currentKeyword,
          limit: _pageSize,
          page: nextPage,
          topicId: _resolvedTopicId,
        ),
      );

      if (requestId != _requestId) return;

      result.fold(
        (failure) {
          final latest = state.value;
          if (latest == null) return;

          state = AsyncValue.data(
            latest.copyWith(
              authors: latest.authors.copyWith(isLoadingMore: false),
            ),
          );
        },
        (paged) {
          _resolvedTopicId ??= paged.topicId;
          _currentPage = nextPage;

          final latest = state.value;
          if (latest == null) return;

          state = AsyncValue.data(
            latest.copyWith(
              authors: latest.authors.copyWith(
                items: [...latest.authors.items, ...paged.items],
                currentPage: nextPage,
                hasMore: paged.hasMore,
                isLoadingMore: false,
              ),
            ),
          );
        },
      );
    } finally {
      if (requestId == _requestId) {
        _pageGuard.release(nextPage);
      }
    }
  }

  Future<void> _loadTopicMatrix(List<AuthorEntity> authors) async {
    final requestId = ++_matrixRequestId;

    final result = await ref.read(getAuthorTopicMatrixUseCaseProvider)(
      GetAuthorTopicMatrixParams(
        authorIds: authors.take(5).map((author) => author.id).toList(),
      ),
    );

    if (requestId != _matrixRequestId) return;

    final latest = state.value;
    if (latest == null) return;

    result.fold(
      (failure) =>
          state = AsyncValue.data(latest.copyWith(isLoadingMatrix: false)),
      (matrix) => state = AsyncValue.data(
        latest.copyWith(topicMatrix: matrix, isLoadingMatrix: false),
      ),
    );
  }
}
