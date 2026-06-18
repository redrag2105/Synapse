import 'author_entity.dart';
import 'publication_entity.dart';

class AuthorDetailEntity {
  final AuthorEntity profile;
  final List<PublicationEntity> topicWorks;

  const AuthorDetailEntity({
    required this.profile,
    required this.topicWorks,
  });
}
