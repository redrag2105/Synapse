import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/app/utils/app_logger.dart';
import 'package:synapse/domain/entities/publication_entity.dart';
import 'package:synapse/domain/entities/topic_entity.dart';
import 'package:synapse/domain/usecases/publication/search_publications_usecase.dart';

final publicationSearchControllerProvider =
    AsyncNotifierProvider.autoDispose<
      PublicationSearchController,
      List<PublicationEntity>
    >(PublicationSearchController.new);

class PublicationSearchController
    extends AsyncNotifier<List<PublicationEntity>> {
  final Map<String, List<PublicationEntity>> _cache = {};

  KeepAliveLink? _link;
  Timer? _timer;

  int _currentRequestId = 0;

  String lastQuery = '';

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
      state = const AsyncValue.data([]);
      return;
    }

    lastQuery = keyword;
    _keepAliveTemporarily();

    final requestId = ++_currentRequestId;

    if (_cache.containsKey(normalizedKeyword)) {
      AppLogger.i('⚡ Lấy kết quả từ Cache cho từ khóa: "$keyword" (0ms)');
      state = AsyncValue.data(_cache[normalizedKeyword]!);
      return;
    }

    AppLogger.i('🔍 Không có Cache. Bắt đầu tải API cho: "$keyword"');
    final stopwatch = Stopwatch()..start();

    state = const AsyncValue.loading();

    final useCase = ref.read(searchPublicationsUseCaseProvider);
    final result = await useCase(
      SearchPublicationsParams(keyword: normalizedKeyword),
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

        _cache[normalizedKeyword] = publications;

        if (requestId != _currentRequestId) {
          AppLogger.d(
            '🚫 Đã hủy update giao diện cho "$keyword" do có truy vấn mới hơn.',
          );
          return;
        }

        state = AsyncValue.data(publications);
      },
    );
  }

  Future<void> searchByTopicId(TopicEntity topic) async {
    final topicId = topic.id.split('/').last;

    lastQuery = topic.displayName;

    _keepAliveTemporarily();

    final requestId = ++_currentRequestId;

    if (_cache.containsKey(topicId)) {
      AppLogger.i('⚡ Lấy từ Cache cho Topic ID: $topicId (0ms)');
      state = AsyncValue.data(_cache[topicId]!);
      return;
    }

    AppLogger.i('🚀 Bỏ qua quét từ khóa! Tìm thẳng bài báo cho ID: $topicId');
    final stopwatch = Stopwatch()..start();

    state = const AsyncValue.loading();

    final pubRepo = ref.read(publicationRepositoryProvider);
    final result = await pubRepo.getPublicationsByTopicId(topicId);

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

        _cache[topicId] = publications;

        if (requestId != _currentRequestId) {
          AppLogger.d(
            '🚫 Đã hủy update giao diện cho Topic "$topicId" do có truy vấn mới hơn.',
          );
          return;
        }

        state = AsyncValue.data(publications);
      },
    );
  }
}
