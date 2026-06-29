import 'package:synapse/domain/entities/keyword_entity.dart';

class KeywordModel extends KeywordEntity {
  const KeywordModel({
    required super.id,
    required super.displayName,
    super.worksCount,
    super.citedByCount,
  });

  factory KeywordModel.fromJson(Map<String, dynamic> json) {
    return KeywordModel(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? 'Unknown Keyword',
      worksCount: json['works_count'] as int? ?? 0,
      citedByCount: json['cited_by_count'] as int? ?? 0,
    );
  }

  /// Parses OpenAlex works `group_by` rows keyed on keywords.id.
  factory KeywordModel.fromGroupByJson(Map<String, dynamic> json) {
    return KeywordModel(
      id: json['key'].toString(),
      displayName: json['key_display_name'].toString(),
      worksCount: json['count'] as int? ?? 0,
    );
  }
}
