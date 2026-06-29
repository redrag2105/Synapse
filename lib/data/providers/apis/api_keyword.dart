import 'package:dio/dio.dart';

/// API contract for OpenAlex [Keywords](https://developers.openalex.org/api-reference/keywords).
abstract class ApiKeyword {
  /// GET /keywords/{id}
  Future<Map<String, dynamic>> getKeywordById({
    required String id,
    String? select,
  });

  /// GET /keywords — list, search, filter, sort, and paginate keywords.
  Future<Map<String, dynamic>> getKeywords({
    String? search,
    String? filter,
    String? sort,
    int page = 1,
    int perPage = 25,
    String? select,
  });

  /// GET /autocomplete/keywords
  Future<dynamic> autocompleteKeywords({required String query});
}

class ApiKeywordImpl implements ApiKeyword {
  final Dio _dio;

  ApiKeywordImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getKeywordById({
    required String id,
    String? select,
  }) async {
    final queryParams = <String, dynamic>{};
    if (select != null && select.isNotEmpty) queryParams['select'] = select;

    final response = await _dio.get(
      '/keywords/$id',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getKeywords({
    String? search,
    String? filter,
    String? sort,
    int page = 1,
    int perPage = 25,
    String? select,
  }) async {
    final safePerPage = perPage > 200 ? 200 : perPage;

    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': safePerPage,
    };

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (filter != null && filter.isNotEmpty) queryParams['filter'] = filter;
    if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;
    if (select != null && select.isNotEmpty) queryParams['select'] = select;

    final response = await _dio.get('/keywords', queryParameters: queryParams);

    return response.data;
  }

  @override
  Future<dynamic> autocompleteKeywords({required String query}) async {
    final response = await _dio.get(
      '/autocomplete/keywords',
      queryParameters: {'q': query},
    );
    return response.data;
  }
}
