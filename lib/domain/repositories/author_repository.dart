import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/author_entity.dart';

abstract class AuthorRepository {
  Future<Either<Failure, List<AuthorEntity>>> getTopAuthorsByTopicId(
    String topicId, {
    int limit = 10,
  });
}
