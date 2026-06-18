class PagedResult<T> {
  final List<T> items;
  final bool hasMore;
  final String? nextCursor;

  const PagedResult({
    required this.items,
    this.hasMore = false,
    this.nextCursor,
  });
}
