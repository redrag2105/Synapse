import 'package:flutter/material.dart';

/// Distance from the bottom of the list at which the next page is requested.
const double kPaginationPrefetchThreshold = 700;

/// Minimum downward scroll after a fetch completes before another page may load.
const double kPaginationMinScrollAdvance = 200;

/// Shared bottom-of-list loading spinner used across paginated screens.
class PaginationLoadingIndicator extends StatelessWidget {
  const PaginationLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3.6,
          ),
        ),
      ),
    );
  }
}

class PaginationFooter extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;

  const PaginationFooter({
    super.key,
    required this.isLoading,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && !hasMore) {
      return const SizedBox(height: 32);
    }

    if (isLoading) {
      return const PaginationLoadingIndicator();
    }

    return const SizedBox.shrink();
  }
}

bool shouldTriggerPaginationFromPosition(
  ScrollMetrics metrics, {
  double threshold = kPaginationPrefetchThreshold,
}) {
  if (metrics.maxScrollExtent <= 0) return false;

  if (metrics.maxScrollExtent <= threshold) {
    return metrics.pixels >= metrics.maxScrollExtent;
  }

  return metrics.pixels >= metrics.maxScrollExtent - threshold;
}

bool shouldTriggerPagination(
  ScrollNotification notification, {
  double threshold = kPaginationPrefetchThreshold,
}) {
  return shouldTriggerPaginationFromPosition(
    notification.metrics,
    threshold: threshold,
  );
}

/// Ensures only one page number is in flight per controller instance.
class InFlightPageGuard {
  int? _page;

  bool get hasPageInFlight => _page != null;

  int? get pageInFlight => _page;

  bool tryAcquire(int page) {
    if (_page != null) return false;
    _page = page;
    return true;
  }

  void release(int page) {
    if (_page == page) {
      _page = null;
    }
  }

  void reset() {
    _page = null;
  }
}

/// Coalesces scroll events and prevents chained page fetches during hard flings.
///
/// Call [onScroll] on every scroll tick so the post-load barrier uses the
/// latest position — not the position from when the fetch was first triggered.
class ScrollPaginationLock {
  bool _inFlight = false;
  double _lastKnownPixels = 0;
  double? _barrierPixels;

  bool get isLocked => _inFlight;

  void reset() {
    _inFlight = false;
    _barrierPixels = null;
    _lastKnownPixels = 0;
  }

  /// Track the latest scroll offset on every scroll notification.
  void onScroll(ScrollMetrics metrics) {
    _lastKnownPixels = metrics.pixels;

    // Release the lock once the user has scrolled into the newly loaded content.
    if (_inFlight &&
        _barrierPixels != null &&
        metrics.pixels >= _barrierPixels!) {
      _inFlight = false;
      _barrierPixels = null;
    }
  }

  void tryLoad({
    required ScrollMetrics metrics,
    required bool canLoadMore,
    required bool isLoadingMore,
    required Future<void> Function() onLoadMore,
    double prefetchThreshold = kPaginationPrefetchThreshold,
  }) {
    onScroll(metrics);

    if (_inFlight || isLoadingMore || !canLoadMore) return;

    if (!shouldTriggerPaginationFromPosition(
      metrics,
      threshold: prefetchThreshold,
    )) {
      return;
    }

    _inFlight = true;
    _barrierPixels = null;

    onLoadMore().whenComplete(() {
      // Keep [_inFlight] true until [onScroll] sees the user advance past this
      // point — prevents page N+1 firing the instant page N finishes while the
      // user is still flinging through the prefetch zone.
      _barrierPixels = _lastKnownPixels + kPaginationMinScrollAdvance;
    });
  }
}
