import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/app/types/paginated_list_state.dart';
import 'package:synapse/domain/entities/author_entity.dart';
import 'package:synapse/domain/entities/author_topic_matrix_entity.dart';
import 'package:synapse/domain/entities/global_author_insights_entity.dart';
import 'package:synapse/domain/usecases/author/get_author_topic_matrix_usecase.dart';
import 'package:synapse/domain/usecases/author/get_global_author_insights_usecase.dart';
import 'package:synapse/domain/usecases/author/get_top_authors_usecase.dart';

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
      globalInsights:
          clearInsights ? null : (globalInsights ?? this.globalInsights),
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
  static const int _apiBatchSize = 200;

  String _currentKeyword = '';
  String lastQuery = '';
  int _requestId = 0;
  int _matrixRequestId = 0;
  int _insightsRequestId = 0;
  bool _isLoadingMoreInFlight = false;

  List<AuthorEntity> _authorBuffer = [];

  String get currentKeyword => _currentKeyword;

  bool get isGlobalView => _currentKeyword.isEmpty;

  @override
  FutureOr<TopAuthorsViewState> build() {
    return const TopAuthorsViewState();
  }

  List<AuthorEntity> _mergeAuthors(
    List<AuthorEntity> existing,
    List<AuthorEntity> incoming,
  ) {
    final byId = <String, AuthorEntity>{
      for (final author in existing) author.id: author,
    };

    for (final author in incoming) {
      byId[author.id] = author;
    }

    return byId.values.toList()
      ..sort((a, b) => b.worksCount.compareTo(a.worksCount));
  }

  bool _hasMoreToShow(int displayedCount) {
    return displayedCount < _authorBuffer.length;
  }

  Future<void> fetchTopAuthors(
    String keyword, {
    bool saveHistory = true,
    int? limit,
  }) async {
    final trimmed = keyword.trim();
    final isGlobal = trimmed.isEmpty;
    final displayLimit = limit ?? _pageSize;
    final apiLimit = limit ?? _apiBatchSize;

    _currentKeyword = trimmed;
    _authorBuffer = [];

    if (saveHistory) {
      lastQuery = isGlobal ? '' : trimmed;
    }

    final requestId = ++_requestId;
    state = const AsyncValue.loading();

    final result = await ref.read(getTopAuthorsUseCaseProvider)(
      GetTopAuthorsParams(
        keyword: _currentKeyword,
        limit: apiLimit,
      ),
    );

    if (requestId != _requestId) return;

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (paged) {
        _authorBuffer = _mergeAuthors([], paged.items);

        final visible = _authorBuffer.take(displayLimit).toList();

        state = AsyncValue.data(
          TopAuthorsViewState(
            authors: TopAuthorsListState(
              items: visible,
              currentPage: 1,
              hasMore: limit == null && _hasMoreToShow(visible.length),
            ),
          ),
        );

        if (limit == null) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            unawaited(_loadSecondaryData(visible, isGlobal: isGlobal));
          });
        }
      },
    );
  }

  Future<void> _loadSecondaryData(
    List<AuthorEntity> authors, {
    required bool isGlobal,
  }) async {
    await _loadGlobalInsights();
    if (!isGlobal || authors.isEmpty) return;
    await _loadTopicMatrix(authors);
  }

  Future<void> loadMore() async {
    if (_isLoadingMoreInFlight) return;

    final current = state.value;
    final authorsState = current?.authors;
    if (current == null ||
        authorsState == null ||
        !authorsState.hasMore ||
        authorsState.isLoadingMore ||
        state.isLoading) {
      return;
    }

    _isLoadingMoreInFlight = true;
    final requestId = ++_requestId;
    final displayedCount = authorsState.items.length;

    state = AsyncValue.data(
      current.copyWith(
        authors: authorsState.copyWith(isLoadingMore: true),
      ),
    );

    try {
      if (displayedCount < _authorBuffer.length) {
        if (requestId != _requestId) return;

        final nextCount = displayedCount + _pageSize;
        final visible = _authorBuffer.take(nextCount).toList();

        state = AsyncValue.data(
          current.copyWith(
            authors: authorsState.copyWith(
              items: visible,
              currentPage: authorsState.currentPage + 1,
              hasMore: _hasMoreToShow(visible.length),
              isLoadingMore: false,
            ),
          ),
        );
        return;
      }

      state = AsyncValue.data(
        current.copyWith(
          authors: authorsState.copyWith(
            hasMore: false,
            isLoadingMore: false,
          ),
        ),
      );
    } finally {
      _isLoadingMoreInFlight = false;
    }
  }

  Future<void> _loadTopicMatrix(List<AuthorEntity> authors) async {
    final requestId = ++_matrixRequestId;
    final current = state.value;
    if (current == null || authors.isEmpty) return;

    state = AsyncValue.data(
      current.copyWith(isLoadingMatrix: true, clearMatrix: true),
    );

    final result = await ref.read(getAuthorTopicMatrixUseCaseProvider)(
      GetAuthorTopicMatrixParams(
        authorIds: authors.take(5).map((author) => author.id).toList(),
      ),
    );

    if (requestId != _matrixRequestId) return;

    final latest = state.value;
    if (latest == null) return;

    result.fold(
      (failure) => state = AsyncValue.data(
        latest.copyWith(isLoadingMatrix: false),
      ),
      (matrix) => state = AsyncValue.data(
        latest.copyWith(topicMatrix: matrix, isLoadingMatrix: false),
      ),
    );
  }

  Future<void> _loadGlobalInsights() async {
    final requestId = ++_insightsRequestId;
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(
      current.copyWith(isLoadingInsights: true, clearInsights: true),
    );

    final result = await ref.read(getGlobalAuthorInsightsUseCaseProvider)(
      GetGlobalAuthorInsightsParams(keyword: _currentKeyword),
    );

    if (requestId != _insightsRequestId) return;

    final latest = state.value;
    if (latest == null) return;

    result.fold(
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
  }
}
