import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:synapse/app/di/providers.dart';
import 'package:synapse/app/utils/app_logger.dart';
import 'package:synapse/domain/entities/keyword_entity.dart';
import 'package:synapse/domain/usecases/publication/get_most_frequent_keywords_usecase.dart';

final mostFrequentKeywordsControllerProvider =
    AsyncNotifierProvider.autoDispose<
      MostFrequentKeywordsController,
      List<KeywordEntity>
    >(MostFrequentKeywordsController.new);

class MostFrequentKeywordsController extends AsyncNotifier<List<KeywordEntity>> {
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

    return _fetchMostFrequent();
  }

  void _keepAliveTemporarily() {
    _timer?.cancel();
    _link ??= ref.keepAlive();
    _timer = Timer(const Duration(minutes: 5), () {
      _link?.close();
      _link = null;
    });
  }

  Future<List<KeywordEntity>> _fetchMostFrequent() async {
    _keepAliveTemporarily();

    if (_cache != null) {
      return _cache!;
    }

    final useCase = ref.read(getMostFrequentKeywordsUseCaseProvider);
    final result = await useCase(const GetMostFrequentKeywordsParams(limit: 10));

    return result.fold(
      (failure) => throw Exception(failure.message),
      (keywords) {
        AppLogger.i('Loaded ${keywords.length} most frequent keywords');
        _cache = keywords;
        return keywords;
      },
    );
  }
}
