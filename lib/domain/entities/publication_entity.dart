import 'author_entity.dart';

class PublicationEntity {
  final String id;
  final String title;
  final String? doi;
  final int publicationYear;
  final String? publicationDate;
  final int citationCount;
  final String journalName;
  final List<AuthorEntity> authors;
  final Map<String, dynamic>? abstractInvertedIndex;

  final bool isOa;
  final String? fullTextUrl;
  final List<String> keywords;

  final String articleType;
  final String? volume;
  final String? issue;
  final String? firstPage;
  final List<String> concepts;

  const PublicationEntity({
    required this.id,
    required this.title,
    this.doi,
    required this.publicationYear,
    this.publicationDate,
    required this.citationCount,
    required this.journalName,
    required this.authors,
    this.abstractInvertedIndex,
    this.isOa = false,
    this.fullTextUrl,
    this.keywords = const [],
    this.articleType = 'Article',
    this.volume,
    this.issue,
    this.firstPage,
    this.concepts = const [],
  });
}
