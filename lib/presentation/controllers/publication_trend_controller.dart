import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/app/utils/app_logger.dart';
import 'package:synapse/domain/usecases/publication/get_publication_trend_usecase.dart'; // Import class Params

final publicationTrendControllerProvider =
    AsyncNotifierProvider.autoDispose<
      PublicationTrendController,
      Map<int, int>
    >(PublicationTrendController.new);

class PublicationTrendController extends AsyncNotifier<Map<int, int>> {
  @override
  FutureOr<Map<int, int>> build() {
    return {};
  }

  // Cho phép nhận vào topicId hoặc keyword
  Future<void> fetchTrend({String? topicId, String? keyword}) async {
    AppLogger.i(
      '📊 Đang tải Trend Data | TopicId: $topicId | Keyword: $keyword',
    );
    state = const AsyncValue.loading();
    final stopwatch = Stopwatch()..start();

    final useCase = ref.read(getPublicationTrendUseCaseProvider);

    // Gói vào Params mới
    final result = await useCase(
      GetPublicationTrendParams(topicId: topicId, keyword: keyword),
    );

    result.fold(
      (failure) {
        stopwatch.stop();
        AppLogger.e('⚠️ Lỗi Trend Data: ${failure.message}');
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (trendData) {
        stopwatch.stop();
        AppLogger.i(
          '🎉 Tải Trend Data thành công trong ${stopwatch.elapsedMilliseconds}ms',
        );
        state = AsyncValue.data(trendData);
      },
    );
  }
}
