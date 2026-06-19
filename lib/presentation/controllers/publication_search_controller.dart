import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/app/utils/app_logger.dart';
import 'package:synapse/domain/entities/publication_entity.dart';
import 'package:synapse/domain/entities/topic_entity.dart';
import 'package:synapse/domain/usecases/publication/search_publications_usecase.dart';

class SearchCacheData {
  final List<PublicationEntity> publications;
  final int page;
  final bool hasReachedMax;

  SearchCacheData({
    required this.publications,
    required this.page,
    required this.hasReachedMax,
  });
}

final publicationSearchControllerProvider =
    AsyncNotifierProvider.autoDispose<
      PublicationSearchController,
      List<PublicationEntity>
    >(PublicationSearchController.new);

class PublicationSearchController
    extends AsyncNotifier<List<PublicationEntity>> {
  final Map<String, SearchCacheData> _cache = {};

  KeepAliveLink? _link;
  Timer? _timer;

  int _currentRequestId = 0;

  String lastQuery = '';

  int _currentPage = 1;
  bool _hasReachedMax = false;
  bool _isFetchingNext = false;

  bool get hasReachedMax => _hasReachedMax;

  TopicEntity? _lastTopic;
  bool _isSearchByTopic = false;

  @override
  FutureOr<List<PublicationEntity>> build() {
    _keepAliveTemporarily();

    ref.onDispose(() {
      _timer?.cancel();
      _cache.clear();
      AppLogger.d(
        '🗑️ SearchController đã được dọn dẹp khỏi RAM (Hết hạn Cache)',
      );
    });

    return [];
  }

  void _keepAliveTemporarily() {
    _timer?.cancel();
    _link ??= ref.keepAlive();
    _timer = Timer(const Duration(minutes: 5), () {
      _link?.close();
      _link = null;
    });
  }

  Future<void> search(String keyword) async {
    final normalizedKeyword = keyword.trim().toLowerCase();

    if (normalizedKeyword.isEmpty) {
      lastQuery = '';
      _isSearchByTopic = false;
      state = const AsyncValue.data([]);
      return;
    }

    lastQuery = keyword;
    _isSearchByTopic = false;
    _keepAliveTemporarily();

    final requestId = ++_currentRequestId;

    if (_cache.containsKey(normalizedKeyword)) {
      AppLogger.i('⚡ Lấy kết quả từ Cache cho từ khóa: "$keyword" (0ms)');
      final cachedData = _cache[normalizedKeyword]!;
      _currentPage = cachedData.page;
      _hasReachedMax = cachedData.hasReachedMax;
      state = AsyncValue.data(cachedData.publications);
      return;
    }

    AppLogger.i('🔍 Không có Cache. Bắt đầu tải API cho: "$keyword"');

    _currentPage = 1;
    _hasReachedMax = false;
    state = const AsyncValue.loading();

    final stopwatch = Stopwatch()..start();

    final useCase = ref.read(searchPublicationsUseCaseProvider);
    final result = await useCase(
      SearchPublicationsParams(keyword: normalizedKeyword, page: _currentPage),
    );

    result.fold(
      (failure) {
        if (requestId != _currentRequestId) return;

        stopwatch.stop();
        AppLogger.w(
          '⚠️ Tìm kiếm thất bại sau ${stopwatch.elapsedMilliseconds}ms: ${failure.message}',
        );
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (publications) {
        stopwatch.stop();
        AppLogger.i(
          '🎉 Tìm thấy ${publications.length} bài báo trong ${stopwatch.elapsedMilliseconds}ms',
        );

        if (requestId != _currentRequestId) {
          AppLogger.d(
            '🚫 Đã hủy update giao diện cho "$keyword" do có truy vấn mới hơn.',
          );
          return;
        }

        _hasReachedMax = publications.length < 25;

        _cache[normalizedKeyword] = SearchCacheData(
          publications: publications,
          page: _currentPage,
          hasReachedMax: _hasReachedMax,
        );

        state = AsyncValue.data(publications);
      },
    );
  }

  Future<void> searchByTopicId(TopicEntity topic) async {
    final topicId = topic.id.split('/').last;

    lastQuery = topic.displayName;
    _lastTopic = topic;
    _isSearchByTopic = true;
    _keepAliveTemporarily();

    final requestId = ++_currentRequestId;

    if (_cache.containsKey(topicId)) {
      AppLogger.i('⚡ Lấy từ Cache cho Topic ID: $topicId (0ms)');
      final cachedData = _cache[topicId]!;
      _currentPage = cachedData.page;
      _hasReachedMax = cachedData.hasReachedMax;
      state = AsyncValue.data(cachedData.publications);
      return;
    }

    AppLogger.i('🚀 Bỏ qua quét từ khóa! Tìm thẳng bài báo cho ID: $topicId');

    _currentPage = 1;
    _hasReachedMax = false;
    state = const AsyncValue.loading();

    final stopwatch = Stopwatch()..start();

    final pubRepo = ref.read(publicationRepositoryProvider);
    final result = await pubRepo.getPublicationsByTopicId(
      topicId,
      page: _currentPage,
    );

    result.fold(
      (failure) {
        if (requestId != _currentRequestId) return;

        state = AsyncValue.error(failure, StackTrace.current);
      },
      (publications) {
        stopwatch.stop();
        AppLogger.i(
          '🎉 Tìm thành công ${publications.length} bài báo trong ${stopwatch.elapsedMilliseconds}ms',
        );

        if (requestId != _currentRequestId) {
          AppLogger.d(
            '🚫 Đã hủy update giao diện cho Topic "$topicId" do có truy vấn mới hơn.',
          );
          return;
        }

        _hasReachedMax = publications.length < 25;

        _cache[topicId] = SearchCacheData(
          publications: publications,
          page: _currentPage,
          hasReachedMax: _hasReachedMax,
        );

        state = AsyncValue.data(publications);
      },
    );
  }

  Future<void> loadMore() async {
    if (_isFetchingNext || _hasReachedMax || state.value == null) return;

    _isFetchingNext = true;
    final nextPage = _currentPage + 1;
    final requestId = _currentRequestId;

    AppLogger.i('🔄 Đang tải thêm trang $nextPage...');

    if (_isSearchByTopic && _lastTopic != null) {
      final topicId = _lastTopic!.id.split('/').last;
      final pubRepo = ref.read(publicationRepositoryProvider);

      final result = await pubRepo.getPublicationsByTopicId(
        topicId,
        page: nextPage,
      );

      result.fold(
        (failure) => AppLogger.w(
          '⚠️ Lỗi khi tải thêm trang $nextPage: ${failure.message}',
        ),
        (newPubs) {
          if (requestId != _currentRequestId) return;

          _hasReachedMax = newPubs.length < 25;
          _currentPage = nextPage;

          final updatedList = [...state.value!, ...newPubs];
          _cache[topicId] = SearchCacheData(
            publications: updatedList,
            page: _currentPage,
            hasReachedMax: _hasReachedMax,
          );

          state = AsyncValue.data(updatedList);
          AppLogger.i('✅ Đã tải và nối thêm ${newPubs.length} bài báo');
        },
      );
    } else {
      final normalizedKeyword = lastQuery.trim().toLowerCase();
      final useCase = ref.read(searchPublicationsUseCaseProvider);

      final result = await useCase(
        SearchPublicationsParams(keyword: normalizedKeyword, page: nextPage),
      );

      result.fold(
        (failure) => AppLogger.w(
          '⚠️ Lỗi khi tải thêm trang $nextPage: ${failure.message}',
        ),
        (newPubs) {
          if (requestId != _currentRequestId) return;

          _hasReachedMax = newPubs.length < 25;
          _currentPage = nextPage;

          final updatedList = [...state.value!, ...newPubs];
          _cache[normalizedKeyword] = SearchCacheData(
            publications: updatedList,
            page: _currentPage,
            hasReachedMax: _hasReachedMax,
          );

          state = AsyncValue.data(updatedList);
          AppLogger.i('✅ Đã tải và nối thêm ${newPubs.length} bài báo');
        },
      );
    }

    _isFetchingNext = false;
  }
}
