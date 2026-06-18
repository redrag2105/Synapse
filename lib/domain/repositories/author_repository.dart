import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/types/paged_result.dart';
import 'package:synapse/app/types/paginated_list_state.dart';
import 'package:synapse/domain/entities/author_entity.dart';
import 'package:synapse/domain/entities/publication_entity.dart';
import 'package:synapse/domain/entities/author_topic_matrix_entity.dart';
import 'package:synapse/domain/entities/global_author_insights_entity.dart';

abstract class AuthorRepository {
  Future<Either<Failure, PagedResult<AuthorEntity>>> getTopAuthorsByKeyword(
    String keyword, {
    int limit = PaginatedListState.defaultPageSize,
  });

  Future<Either<Failure, AuthorEntity>> getAuthorById(
    String authorId, {
    bool includeTopics = false,
  });

  Future<Either<Failure, List<PublicationEntity>>> getAuthorWorksByTopic(
    String authorId,
    String keyword, {
    int page = 1,
    int limit = PaginatedListState.defaultPageSize,
  });

  Future<Either<Failure, AuthorTopicMatrix>> getAuthorTopicMatrix(
    List<String> authorIds, {
    int maxAuthors = 5,
    int maxTopics = 5,
  });

  Future<Either<Failure, GlobalAuthorInsights>> getGlobalAuthorInsights({
    String keyword = '',
  });
}
