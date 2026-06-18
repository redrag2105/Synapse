import 'package:flutter/cupertino.dart';
import 'package:synapse/app/config/app_colors.dart';

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: isLoading
            ? const CupertinoActivityIndicator(color: AppColors.brandBlue900)
            : const SizedBox.shrink(),
      ),
    );
  }
}

bool shouldTriggerPagination(
  ScrollNotification notification, {
  double threshold = 200,
}) {
  if (notification.metrics.maxScrollExtent <= 0) return false;
  return notification.metrics.pixels >=
      notification.metrics.maxScrollExtent - threshold;
}
