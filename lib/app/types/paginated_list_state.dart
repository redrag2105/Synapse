class PaginatedListState<T> {
  static const int defaultPageSize = 25;

  final List<T> items;
  final int currentPage;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  const PaginatedListState({
    this.items = const [],
    this.currentPage = 0,
    this.nextCursor,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  PaginatedListState<T> copyWith({
    List<T>? items,
    int? currentPage,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool clearNextCursor = false,
  }) {
    return PaginatedListState<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
