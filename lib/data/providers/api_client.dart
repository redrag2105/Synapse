import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/utils/app_logger.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.openalex.org',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        const apiKey = String.fromEnvironment('API_KEY');

        if (apiKey.isNotEmpty) {
          options.queryParameters['api_key'] = apiKey;
        }

        AppLogger.d('🚀 [API REQ] ${options.method} ${options.uri}');
        options.extra['start_time'] = DateTime.now().millisecondsSinceEpoch;

        return handler.next(options);
      },
      onResponse: (response, handler) {
        final startTime = response.requestOptions.extra['start_time'] as int?;
        final timeMs = startTime != null
            ? DateTime.now().millisecondsSinceEpoch - startTime
            : 0;
        AppLogger.i(
          '✅ [API RES] [${response.statusCode}] ${response.requestOptions.path} (${timeMs}ms)',
        );

        return handler.next(response);
      },
      onError: (DioException e, handler) {
        final statusCode = e.response?.statusCode;
        AppLogger.e(
          '❌ [API ERR] [$statusCode] ${e.requestOptions.path}',
          e.message,
        );

        return handler.next(e);
      },
    ),
  );

  return dio;
});
