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
    String? select,
  }) async {
    final safePerPage = perPage > 100 ? 100 : perPage;

    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': safePerPage,
    };

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (filter != null && filter.isNotEmpty) queryParams['filter'] = filter;
    if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;
    if (groupBy != null && groupBy.isNotEmpty) {
      queryParams['group_by'] = groupBy;
    }
    if (select != null && select.isNotEmpty) queryParams['select'] = select;

    final response = await _dio.get('/works', queryParameters: queryParams);

    return response.data;
  }
}
