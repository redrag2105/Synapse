import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/routes/app_routes.dart';
import 'package:synapse/domain/entities/keyword_entity.dart';
import 'package:synapse/presentation/controllers/publication_search_controller.dart';

void openKeywordInSearch(
  BuildContext context,
  WidgetRef ref,
  KeywordEntity keyword,
) {
  ref
      .read(publicationSearchControllerProvider.notifier)
      .search(keyword.displayName);
  context.go(AppRoutes.search);
}
