import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/routes/app_routes.dart';
import 'package:synapse/domain/entities/keyword_entity.dart';

/// Opens Keyword Detail analytics for [keyword].
void openKeywordDetail(BuildContext context, KeywordEntity keyword) {
  context.push(AppRoutes.keywordDetail(keyword.displayName));
}
