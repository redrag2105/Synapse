class KeywordEntity {
  final String id;
  final String displayName;
  final int worksCount;
  final int citedByCount;

  const KeywordEntity({
    required this.id,
    required this.displayName,
    this.worksCount = 0,
    this.citedByCount = 0,
  });
}
