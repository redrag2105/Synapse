import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/utils/app_logger.dart';

mixin RequestDeduplicator {
  final Map<String, dynamic> _cache = {};
  final Map<String, Future<dynamic>> _inFlight = {};

  Future<Either<Failure, T>> deduplicate<T>({
    required String cacheKey,
    required Future<Either<Failure, T>> Function() action,
    bool useCache = true,
  }) async {
    if (useCache && _cache.containsKey(cacheKey)) {
      return Right(_cache[cacheKey] as T);
    }

    if (_inFlight.containsKey(cacheKey)) {
      AppLogger.i(
        '⚡ Trùng lặp request [$cacheKey]. Đang gộp chung (Deduplication)...',
      );
      return await _inFlight[cacheKey] as Future<Either<Failure, T>>;
    }

    final futureRequest = action();
    _inFlight[cacheKey] = futureRequest;

    try {
      final result = await futureRequest;

      result.fold((failure) => null, (data) {
        if (useCache) _cache[cacheKey] = data;
      });

      return result;
    } finally {
      _inFlight.remove(cacheKey);
    }
  }

  void clearCache() {
    _cache.clear();
  }
}
