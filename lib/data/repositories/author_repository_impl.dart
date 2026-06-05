import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/utils/error_handler.dart';
import 'package:synapse/data/models/author_model.dart';
import 'package:synapse/data/providers/apis/api_author.dart';
import 'package:synapse/domain/entities/author_entity.dart';
import 'package:synapse/domain/repositories/author_repository.dart';

class AuthorRepositoryImpl implements AuthorRepository {
  final ApiAuthor _apiAuthor;

  AuthorRepositoryImpl(this._apiAuthor);

  @override
  Future<Either<Failure, List<AuthorEntity>>> getTopAuthorsByTopicId(
    String topicId, {
    int limit = 10,
  }) async {
    try {
      final response = await _apiAuthor.getAuthors(
        // Bộ lọc: Tìm tác giả có viết bài về topic này
        filter: 'topics.id:$topicId',
        // Sắp xếp: Tác giả có nhiều bài báo nhất lên đầu
        sort: 'works_count:desc',
        perPage: limit,
        // Tối ưu payload: Chỉ lấy những trường mà AuthorEntity thực sự cần
        select:
            'id,display_name,orcid,works_count,cited_by_count,summary_stats,last_known_institutions',
      );

      final results = response['results'] as List;

      // Chuyển đổi JSON thành Model (Entity)
      final authors = results.map((e) => AuthorModel.fromJson(e)).toList();

      return Right(authors);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
