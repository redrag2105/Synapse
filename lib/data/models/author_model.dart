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
  });

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

    return AuthorModel(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? 'Unknown Author',
      orcid: json['orcid'] as String?,
      worksCount: json['works_count'] as int? ?? 0,
      citedByCount: json['cited_by_count'] as int? ?? 0,
      hIndex: hIndex,
      i10Index: i10Index,
      lastKnownInstitutionName: institutionName,
      lastKnownInstitutionCountry: institutionCountry,
    );
  }
}
