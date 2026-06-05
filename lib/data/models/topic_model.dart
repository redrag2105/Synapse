import 'package:synapse/domain/entities/topic_entity.dart';

class TopicModel extends TopicEntity {
  const TopicModel({
    required super.id,
    required super.displayName,
    super.description,
    super.keywords,
    super.worksCount,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? 'Unknown Topic',
      description: json['description'] as String?,
      keywords:
          (json['keywords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      worksCount: json['works_count'] as int? ?? 0,
    );
  }
}
