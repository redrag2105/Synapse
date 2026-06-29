import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/app/utils/app_logger.dart';
import 'package:synapse/domain/entities/keyword_entity.dart';
import 'package:synapse/domain/usecases/keyword/get_trending_keywords_usecase.dart';

final trendingKeywordsControllerProvider =
    AsyncNotifierProvider.autoDispose<
      TrendingKeywordsController,
      List<KeywordEntity>
    >(TrendingKeywordsController.new);

class TrendingKeywordsController extends AsyncNotifier<List<KeywordEntity>> {
  List<KeywordEntity>? _cache;
  KeepAliveLink? _link;
  Timer? _timer;

  @override
  FutureOr<List<KeywordEntity>> build() async {
    _keepAliveTemporarily();

    ref.onDispose(() {
      _timer?.cancel();
      _cache = null;
    });

    return _fetchTrendingKeywords();
  }

  void _keepAliveTemporarily() {
    _timer?.cancel();
    _link ??= ref.keepAlive();
    _timer = Timer(const Duration(minutes: 5), () {
      _link?.close();
      _link = null;
    });
  }

  Future<List<KeywordEntity>> _fetchTrendingKeywords() async {
    _keepAliveTemporarily();

    if (_cache != null) {
      return _cache!;
    }

    final useCase = ref.read(getTrendingKeywordsUseCaseProvider);
    final result = await useCase(const GetTrendingKeywordsParams(limit: 6));

    return result.fold(
      (failure) => throw Exception(failure.message),
      (keywords) {
        AppLogger.i('Loaded ${keywords.length} trending keywords');
        _cache = keywords;
        return keywords;
      },
    );
  }
}
