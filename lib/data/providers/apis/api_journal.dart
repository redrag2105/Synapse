import 'package:dio/dio.dart';

/// Interface định nghĩa các API contract cho thực thể Journal (Sources)
abstract class ApiJournal {
  /// Lấy thông tin chi tiết của một tạp chí (source) thông qua OpenAlex ID hoặc ISSN.
  Future<Map<String, dynamic>> getJournalById({
    required String id,
    String? select,
  });

  /// Lấy danh sách tạp chí kèm theo các tùy chọn lọc, tìm kiếm, sắp xếp, gom nhóm và phân trang.
  Future<Map<String, dynamic>> getJournals({
    String? search,
    String? filter,
    String? sort,
    String? groupBy,
    int page = 1,
    int perPage = 25,
    String? select,
  });
}

/// Implementation thực tế sử dụng Dio
class ApiJournalImpl implements ApiJournal {
  final Dio _dio;

  ApiJournalImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getJournalById({
    required String id,
    String? select,
  }) async {
    final queryParams = <String, dynamic>{};
    if (select != null && select.isNotEmpty) queryParams['select'] = select;

    final response = await _dio.get(
      '/sources/$id', // Endpoint lấy một source duy nhất
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getJournals({
    String? search,
    String? filter,
    String? sort,
    String? groupBy,
    int page = 1,
    int perPage = 25,
    String? select,
  }) async {
    // Đảm bảo giới hạn per_page không vượt quá 100 theo đúng tài liệu OpenAPI
    final safePerPage = perPage > 100 ? 100 : perPage;

    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': safePerPage,
    };

    // Chỉ thêm vào query map nếu có giá trị để URL được gọn gàng
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (filter != null && filter.isNotEmpty) queryParams['filter'] = filter;
    if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;
    if (groupBy != null && groupBy.isNotEmpty) {
      queryParams['group_by'] = groupBy;
    }
    if (select != null && select.isNotEmpty) queryParams['select'] = select;

    final response = await _dio.get(
      '/sources', // Endpoint lấy danh sách sources
      queryParameters: queryParams,
    );

    return response.data;
  }
}
