import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/domain/usecases/publication/get_publication_trend_usecase.dart';

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

  Future<void> fetchTrend(String keyword) async {
    if (keyword.trim().isEmpty) return;

    state = const AsyncValue.loading();

    final useCase = ref.read(getPublicationTrendUseCaseProvider);
    final result = await useCase(GetPublicationTrendParams(keyword: keyword));

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (trendData) => state = AsyncValue.data(trendData),
    );
  }
}
