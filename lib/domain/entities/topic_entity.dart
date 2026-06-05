class TopicEntity {
  final String id;
  final String displayName;
  final String? description;
  final List<String> keywords;
  final int worksCount;

  const TopicEntity({
    required this.id,
    required this.displayName,
    this.description,
    this.keywords = const [],
    this.worksCount = 0,
  });
}
