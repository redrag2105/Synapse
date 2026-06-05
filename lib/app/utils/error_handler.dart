import 'package:dio/dio.dart';
import 'package:synapse/app/types/failure.dart';

class ErrorHandler {
  static Failure handle(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return const NetworkFailure(
          'Lỗi kết nối mạng. Vui lòng kiểm tra lại đường truyền.',
        );
      }

      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        if (statusCode == 404) {
          return const NotFoundFailure('Không tìm thấy dữ liệu trên hệ thống.');
        }
        if (statusCode == 429) {
          return const RateLimitFailure(
            'Hệ thống đang quá tải. Vui lòng thử lại sau.',
          );
        }
        if (statusCode == 400) {
          return const BadRequestFailure(
            'Yêu cầu không hợp lệ. Vui lòng kiểm tra lại tham số.',
          );
        }
        if (statusCode == 401) {
          return const ServerFailure(
            'Lỗi xác thực: API Key của bạn không hợp lệ hoặc chưa được nạp đúng cách.',
          );
        }
      }

      return ServerFailure(
        error.message ?? 'Đã xảy ra lỗi hệ thống từ OpenAlex.',
      );
    }

    if (error.toString().contains('NOT_FOUND')) {
      return const NotFoundFailure('Không tìm thấy dữ liệu yêu cầu.');
    }

    return ServerFailure('Đã xảy ra lỗi không xác định: ${error.toString()}');
  }
}
