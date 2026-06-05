import 'package:synapse/data/models/author_model.dart';
import 'package:synapse/domain/entities/publication_entity.dart';

class PublicationModel extends PublicationEntity {
  const PublicationModel({
    required super.id,
    required super.title,
    super.doi,
    required super.publicationYear,
    super.publicationDate,
    required super.citationCount,
    required super.journalName,
    required super.authors,
    super.abstractInvertedIndex,
    super.isOa,
    super.fullTextUrl,
    super.keywords,
    super.articleType,
    super.volume,
    super.issue,
    super.firstPage,
    super.concepts,
  });

  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    String journalName = 'Unknown Journal';
    String? fullTextUrl;
    final primaryLocation = json['primary_location'] as Map<String, dynamic>?;

    if (primaryLocation != null) {
      final source = primaryLocation['source'] as Map<String, dynamic>?;
      if (source != null) {
        journalName = source['display_name'] as String? ?? 'Unknown Journal';
      }
      fullTextUrl =
          primaryLocation['pdf_url'] as String? ??
          primaryLocation['landing_page_url'] as String?;
    }

    List<AuthorModel> parsedAuthors = [];
    final authorships = json['authorships'] as List<dynamic>?;
    if (authorships != null) {
      for (var item in authorships) {
        final authorData = item['author'] as Map<String, dynamic>?;
        if (authorData != null) {
          parsedAuthors.add(AuthorModel.fromJson(authorData));
        }
      }
    }

    List<String> parsedKeywords = [];
    final keywordsData = json['keywords'] as List<dynamic>?;
    if (keywordsData != null) {
      for (var kw in keywordsData) {
        final name = kw['display_name'] as String?;
        if (name != null) parsedKeywords.add(name);
      }
    }

    final biblio = json['biblio'] as Map<String, dynamic>?;

    List<String> parsedConcepts = [];
    final conceptsData = json['concepts'] as List<dynamic>?;
    if (conceptsData != null) {
      for (var concept in conceptsData) {
        final name = concept['display_name'] as String?;
        if (name != null) parsedConcepts.add(name);
      }
    }

    return PublicationModel(
      id: json['id'] as String? ?? '',
      title: json['display_name'] ?? json['title'] ?? 'Untitled',
      doi: json['doi'] as String?,
      publicationYear: json['publication_year'] as int? ?? 0,
      publicationDate: json['publication_date'] as String?,
      citationCount: json['cited_by_count'] as int? ?? 0,
      journalName: journalName,
      authors: parsedAuthors,
      abstractInvertedIndex:
          json['abstract_inverted_index'] as Map<String, dynamic>?,
      isOa: json['open_access']?['is_oa'] as bool? ?? false,
      fullTextUrl: fullTextUrl,
      keywords: parsedKeywords,

      articleType: json['type'] as String? ?? 'Article',
      volume: biblio?['volume']?.toString(),
      issue: biblio?['issue']?.toString(),
      firstPage: biblio?['first_page']?.toString(),
      concepts: parsedConcepts,
    );
  }
}
