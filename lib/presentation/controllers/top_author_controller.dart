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
  static const int _apiBatchSize = 200;

  String _currentKeyword = '';
  String lastQuery = '';
  int _requestId = 0;
  int _matrixRequestId = 0;
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
    bool forceRefresh = false,
  }) async {
    final trimmed = keyword.trim();
    final isGlobal = trimmed.isEmpty;
    final displayLimit = limit ?? _pageSize;
    final apiLimit = limit ?? _apiBatchSize;

    // Tránh fetch lại liên tục nếu đang load hoặc đã có data của chính keyword này
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
    _authorBuffer = [];

    if (saveHistory) {
      lastQuery = isGlobal ? '' : trimmed;
    }

    final requestId = ++_requestId;

    // Khởi chạy fetch Insights ngay lập tức song song với Authors để giảm thời gian chờ
    Future<Either<Failure, GlobalAuthorInsights>>? insightsFuture;
    if (limit == null) {
      insightsFuture = ref.read(getGlobalAuthorInsightsUseCaseProvider)(
        GetGlobalAuthorInsightsParams(keyword: _currentKeyword),
      );
    }

    state = const AsyncValue.loading();

    final result = await ref.read(getTopAuthorsUseCaseProvider)(
      GetTopAuthorsParams(keyword: _currentKeyword, limit: apiLimit),
    );

    if (requestId != _requestId) return;

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (paged) {
        _authorBuffer = _mergeAuthors([], paged.items);

        final visible = _authorBuffer.take(displayLimit).toList();

        // Khởi tạo state với dữ liệu Authors và bật sẵn cờ loading cho các phần phụ
        state = AsyncValue.data(
          TopAuthorsViewState(
            authors: TopAuthorsListState(
              items: visible,
              currentPage: 1,
              hasMore: limit == null && _hasMoreToShow(visible.length),
            ),
            isLoadingInsights: limit == null,
            isLoadingMatrix: limit == null && isGlobal && visible.isNotEmpty,
          ),
        );

        if (limit == null) {
          // 1. Xử lý kết quả Insights đã chạy song song ở trên
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

          // 2. Bắt đầu fetch Matrix (bắt buộc phải đợi Authors vì cần ID)
          if (isGlobal && visible.isNotEmpty) {
            unawaited(_loadTopicMatrix(visible));
          }
        }
      },
    );
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
      current.copyWith(authors: authorsState.copyWith(isLoadingMore: true)),
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
          authors: authorsState.copyWith(hasMore: false, isLoadingMore: false),
        ),
      );
    } finally {
      _isLoadingMoreInFlight = false;
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
