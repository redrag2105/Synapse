import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/app/utils/app_logger.dart';
import 'package:synapse/domain/entities/topic_entity.dart';

final trendingTopicControllerProvider =
    AsyncNotifierProvider.autoDispose<
      TrendingTopicController,
      List<TopicEntity>
    >(TrendingTopicController.new);

class TrendingTopicController extends AsyncNotifier<List<TopicEntity>> {
  List<TopicEntity>? _cache;
  KeepAliveLink? _link;
  Timer? _timer;

  @override
  FutureOr<List<TopicEntity>> build() async {
    _keepAliveTemporarily();

    ref.onDispose(() {
      _timer?.cancel();
      _cache = null;
      AppLogger.d('🗑️ TrendingTopicController đã được dọn dẹp khỏi RAM');
    });

    return await _fetchTrendingTopics();
  }

  void _keepAliveTemporarily() {
    _timer?.cancel();
    _link ??= ref.keepAlive();
    _timer = Timer(const Duration(minutes: 5), () {
      _link?.close();
      _link = null;
    });
  }

  Future<List<TopicEntity>> _fetchTrendingTopics() async {
    _keepAliveTemporarily();

    if (_cache != null) {
      AppLogger.i('⚡ Lấy danh sách Trending Topics từ Cache (0ms)');
      return _cache!;
    }

    AppLogger.i('🔥 Không có Cache. Bắt đầu chạy UseCase lấy Trending Topics');
    final stopwatch = Stopwatch()..start();

    final useCase = ref.read(getTrendingTopicsUseCaseProvider);
    final result = await useCase();

    return result.fold(
      (failure) {
        stopwatch.stop();
        AppLogger.e('⚠️ Lỗi khi tải Trending Topics: ${failure.message}');
        throw Exception(failure.message);
      },
      (topics) {
        stopwatch.stop();
        AppLogger.i(
          '🎉 Tải thành công ${topics.length} Trending Topics trong ${stopwatch.elapsedMilliseconds}ms',
        );
        _cache = topics;
        return topics;
      },
    );
  }

  Future<void> refresh() async {
    AppLogger.i('🔄 Đang làm mới danh sách Trending Topics...');
    _cache = null;
    state = const AsyncValue.loading();
    try {
      final topics = await _fetchTrendingTopics();
      state = AsyncValue.data(topics);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
