class AuthorTopicMatrix {
  final List<String> authorIds;
  final List<String> authorNames;
  final List<String> topicIds;
  final List<String> topicNames;
  final List<List<int>> counts;

  const AuthorTopicMatrix({
    required this.authorIds,
    required this.authorNames,
    required this.topicIds,
    required this.topicNames,
    required this.counts,
  });
}
