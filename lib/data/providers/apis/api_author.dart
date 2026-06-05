import 'package:dio/dio.dart';

/// Interface định nghĩa các API contract cho thực thể Author
abstract class ApiAuthor {
  /// Lấy thông tin chi tiết của một tác giả thông qua OpenAlex ID hoặc ORCID.
  Future<Map<String, dynamic>> getAuthorById({
    required String id,
    String? select,
  });

  /// Lấy danh sách tác giả kèm theo các tùy chọn lọc, tìm kiếm, sắp xếp và phân trang.
  Future<Map<String, dynamic>> getAuthors({
    String? search,
    String? filter,
    String? sort,
    int page = 1,
    int perPage = 25,
    String? select,
  });
}

/// Implementation thực tế sử dụng Dio
class ApiAuthorImpl implements ApiAuthor {
  final Dio _dio;

  ApiAuthorImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getAuthorById({
    required String id,
    String? select,
  }) async {
    // Khởi tạo query parameters, loại bỏ các giá trị null
    final queryParams = <String, dynamic>{};
    if (select != null) queryParams['select'] = select;

    final response = await _dio.get(
      '/authors/$id',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getAuthors({
    String? search,
    String? filter,
    String? sort,
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
    if (select != null && select.isNotEmpty) queryParams['select'] = select;

    final response = await _dio.get('/authors', queryParameters: queryParams);

    return response.data;
  }
}
