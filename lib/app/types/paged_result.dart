class PagedResult<T> {
  final List<T> items;
  final bool hasMore;
  final String? nextCursor;
  final int? totalCount;
  final String? topicId;

  const PagedResult({
    required this.items,
    this.hasMore = false,
    this.nextCursor,
    this.totalCount,
    this.topicId,
  });
}
