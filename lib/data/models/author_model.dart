import 'package:synapse/domain/entities/author_entity.dart';

class AuthorModel extends AuthorEntity {
  const AuthorModel({
    required super.id,
    required super.displayName,
    super.orcid,
    super.worksCount,
    super.citedByCount,
    super.hIndex,
    super.i10Index,
    super.lastKnownInstitutionName,
    super.lastKnownInstitutionCountry,
    super.researchTopics,
  });

  factory AuthorModel.fromGroupByJson(Map<String, dynamic> json) {
    final key = json['key']?.toString() ?? '';
    final id = key.contains('/') ? key.split('/').last : key;

    return AuthorModel(
      id: id,
      displayName: json['key_display_name'] as String? ?? 'Unknown Author',
      worksCount: _parseCount(json['count']),
    );
  }

  static int _parseCount(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    final summaryStats = json['summary_stats'] as Map<String, dynamic>?;
    final hIndex = summaryStats?['h_index'] as int? ?? 0;
    final i10Index = summaryStats?['i10_index'] as int? ?? 0;

    String? institutionName;
    String? institutionCountry;

    final institutions = json['last_known_institutions'] as List<dynamic>?;
    if (institutions != null && institutions.isNotEmpty) {
      final firstInstitution = institutions.first as Map<String, dynamic>;
      institutionName = firstInstitution['display_name'] as String?;
      institutionCountry = firstInstitution['country_code'] as String?;
    }

    final rawId = json['id']?.toString() ?? '';
    final id = rawId.contains('/') ? rawId.split('/').last : rawId;

    final topicsJson = json['topics'] as List<dynamic>?;
    final topics = topicsJson
            ?.map((topic) {
              final map = topic as Map<String, dynamic>;
              final topicId = map['id']?.toString() ?? '';
              return AuthorResearchTopic(
                id: topicId.contains('/') ? topicId.split('/').last : topicId,
                displayName:
                    map['display_name'] as String? ?? 'Unknown Topic',
                count: map['count'] as int? ?? 0,
              );
            })
            .toList() ??
        const <AuthorResearchTopic>[];

    return AuthorModel(
      id: id,
      displayName: json['display_name'] as String? ?? 'Unknown Author',
      orcid: json['orcid'] as String?,
      worksCount: json['works_count'] as int? ?? 0,
      citedByCount: json['cited_by_count'] as int? ?? 0,
      hIndex: hIndex,
      i10Index: i10Index,
      lastKnownInstitutionName: institutionName,
      lastKnownInstitutionCountry: institutionCountry,
      researchTopics: topics,
    );
  }
}
