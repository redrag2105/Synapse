import 'package:dio/dio.dart';

abstract class ApiPublication {
  Future<Map<String, dynamic>> getWorkById({
    required String id,
    String? select,
  });

  Future<Map<String, dynamic>> getWorks({
    String? search,
    String? filter,
    String? sort,
    String? groupBy,
    int page = 1,
    int perPage = 25,
    String? cursor,
    String? select,
  });
}

class ApiPublicationImpl implements ApiPublication {
  final Dio _dio;

  ApiPublicationImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getWorkById({
    required String id,
    String? select,
  }) async {
    final queryParams = <String, dynamic>{};
    if (select != null && select.isNotEmpty) queryParams['select'] = select;

    final response = await _dio.get(
      '/works/$id',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getWorks({
    String? search,
    String? filter,
    String? sort,
    String? groupBy,
    int page = 1,
    int perPage = 25,
    String? cursor,
    String? select,
  }) async {
    final usesGroupBy = groupBy != null && groupBy.isNotEmpty;
    final safePerPage = usesGroupBy
        ? (perPage > 200 ? 200 : perPage)
        : (perPage > 100 ? 100 : perPage);

    final queryParams = <String, dynamic>{
      'per_page': safePerPage,
    };

    if (usesGroupBy) {
      // OpenAlex group_by: only page 1 (max 200 groups). Cursor returns wrong order.
      queryParams['page'] = 1;
      queryParams['group_by'] = groupBy;
    } else {
      queryParams['page'] = page;
    }

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (filter != null && filter.isNotEmpty) queryParams['filter'] = filter;
    if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;
    if (select != null && select.isNotEmpty) queryParams['select'] = select;

    final response = await _dio.get(
      '/works',
      queryParameters: queryParams,
    );

    return response.data;
  }
}
