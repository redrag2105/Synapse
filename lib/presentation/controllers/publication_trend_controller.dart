import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/app/utils/app_logger.dart';
import 'package:synapse/domain/usecases/publication/get_publication_trend_usecase.dart';

final publicationTrendControllerProvider =
    AsyncNotifierProvider.autoDispose<
      PublicationTrendController,
      Map<int, int>
    >(PublicationTrendController.new);

class PublicationTrendController extends AsyncNotifier<Map<int, int>> {
  final Map<String, Map<int, int>> _cache = {};

  KeepAliveLink? _link;
  Timer? _timer;
  int _currentRequestId = 0;

  String lastQuery = '';
  String? lastTopicId;
  String? lastTopicName;

  String? pendingExternalKeyword;
  String? pendingExternalTopicName;

  void setExternalNavigation(String keyword, String topicName) {
    pendingExternalKeyword = keyword;
    pendingExternalTopicName = topicName;
  }

  @override
  FutureOr<Map<int, int>> build() {
    _keepAliveTemporarily();

    ref.onDispose(() {
      _timer?.cancel();
      _cache.clear();
      AppLogger.d('🗑️ TrendController đã được dọn dẹp (Hết hạn Cache)');
    });

    return {};
  }

  void _keepAliveTemporarily() {
    _timer?.cancel();
    _link ??= ref.keepAlive();
    _timer = Timer(const Duration(minutes: 5), () {
      _link?.close();
      _link = null;
    });
  }

  Future<void> fetchTrend({
    String? topicId,
    String? keyword,
    String? topicName,
    bool saveHistory = true,
  }) async {
    _keepAliveTemporarily();
    final requestId = ++_currentRequestId;

    final normalizedKeyword = keyword?.trim();
    final isGlobal =
        (topicId == null &&
        (normalizedKeyword == null || normalizedKeyword.isEmpty));

    if (saveHistory) {
      if (isGlobal) {
        lastQuery = '';
        lastTopicId = null;
        lastTopicName = null;
      } else {
        lastQuery = normalizedKeyword ?? '';
        lastTopicId = topicId;
        lastTopicName = topicName;
      }
    }

    String cacheKey = 'global';
    if (topicId != null) {
      cacheKey = 'topic_$topicId';
    } else if (normalizedKeyword != null && normalizedKeyword.isNotEmpty) {
      cacheKey = 'keyword_$normalizedKeyword';
    }

    if (_cache.containsKey(cacheKey)) {
      AppLogger.i('⚡ Lấy Trend từ Cache cho: $cacheKey (0ms)');
      state = AsyncValue.data(_cache[cacheKey]!);
      return;
    }

    AppLogger.i(
      '📊 Đang tải Trend Data | TopicId: $topicId | Keyword: $keyword',
    );
    state = const AsyncValue.loading();
    final stopwatch = Stopwatch()..start();

    final useCase = ref.read(getPublicationTrendUseCaseProvider);
    final result = await useCase(
      GetPublicationTrendParams(topicId: topicId, keyword: normalizedKeyword),
    );

    result.fold(
      (failure) {
        if (requestId != _currentRequestId) return;
        stopwatch.stop();
        AppLogger.e('⚠️ Lỗi Trend Data: ${failure.message}');
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (trendData) {
        stopwatch.stop();
        AppLogger.i(
          '🎉 Tải Trend Data thành công trong ${stopwatch.elapsedMilliseconds}ms',
        );

        _cache[cacheKey] = trendData;

        if (requestId != _currentRequestId) {
          AppLogger.d('🚫 Đã hủy update Trend do có truy vấn mới hơn.');
          return;
        }

        state = AsyncValue.data(trendData);
      },
    );
  }
}
