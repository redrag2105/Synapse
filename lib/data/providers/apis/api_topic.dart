import 'package:dio/dio.dart';

/// Interface định nghĩa các API contract cho thực thể Topic
abstract class ApiTopic {
  /// Lấy thông tin chi tiết của một chủ đề (Topic) thông qua OpenAlex ID
  Future<Map<String, dynamic>> getTopicById({
    required String id,
    String? select,
  });

  /// Lấy danh sách Topic kèm theo tùy chọn lọc, tìm kiếm, sắp xếp, gom nhóm và phân trang
  Future<Map<String, dynamic>> getTopics({
    String? search,
    String? filter,
    String? sort,
    String? groupBy,
    int page = 1,
    int perPage = 25,
    String? select,
  });

  Future<dynamic> autocompleteTopics({required String query});
}

/// Implementation thực tế sử dụng Dio
class ApiTopicImpl implements ApiTopic {
  final Dio _dio;

  ApiTopicImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getTopicById({
    required String id,
    String? select,
  }) async {
    final queryParams = <String, dynamic>{};
    if (select != null && select.isNotEmpty) queryParams['select'] = select;

    final response = await _dio.get(
      '/topics/$id',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getTopics({
    String? search,
    String? filter,
    String? sort,
    String? groupBy,
    int page = 1,
    int perPage = 25,
    String? select,
  }) async {
    // Đảm bảo giới hạn per_page không vượt quá 100
    final safePerPage = perPage > 100 ? 100 : perPage;

    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': safePerPage,
    };

    // Chỉ thêm vào query map nếu có giá trị
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (filter != null && filter.isNotEmpty) queryParams['filter'] = filter;
    if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;
    if (groupBy != null && groupBy.isNotEmpty) {
      queryParams['group_by'] = groupBy;
    }
    if (select != null && select.isNotEmpty) queryParams['select'] = select;

    final response = await _dio.get('/topics', queryParameters: queryParams);

    return response.data;
  }

  @override
  Future<dynamic> autocompleteTopics({required String query}) async {
    final response = await _dio.get(
      '/autocomplete/topics',
      queryParameters: {'q': query},
    );
    return response.data;
  }
}
