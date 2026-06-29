import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/presentation/screens/author_detail/author_detail_screen.dart';
import 'package:synapse/presentation/screens/discover/discover_screen.dart';
import 'package:synapse/presentation/screens/leading_journals/leading_journals_screen.dart';
import 'package:synapse/presentation/screens/profile/profile_screen.dart';
import 'package:synapse/presentation/screens/publication_detail/publication_detail_screen.dart';
import 'package:synapse/presentation/screens/publication_search/publication_search_screen.dart';
import 'package:synapse/presentation/screens/research_dashboard/research_dashboard_screen.dart';
import 'package:synapse/presentation/screens/trend/trend_screen.dart';
import 'package:synapse/presentation/screens/top_authors/top_authors_screen.dart';
import 'package:synapse/presentation/shell/app_shell_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String discover = '/discover';
  static const String search = '/search';
  static const String publicationDetail = '/detail';
  static const String trend = '/trend';
  static const String dashboard = '/dashboard';
  static const String authors = '/authors';
  static const String journals = '/journals';
  static const String profile = '/profile';

  /// Keyword Detail — research analytics for a single keyword.
  static String keywordDetail(String keyword) =>
      '$dashboard/${Uri.encodeComponent(keyword)}';

  // Legacy aliases kept for existing deep links / references.
  static const String topAuthors = authors;
  static const String topJournals = journals;
}

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _discoverNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'discover');
final _searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final _trendNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'trend');
final _authorsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'authors');
final _journalsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'journals');

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.discover,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == AppRoutes.home) return AppRoutes.discover;
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _discoverNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.discover,
                builder: (context, state) => const DiscoverScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _trendNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.trend,
                builder: (context, state) => const TrendScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.search,
                builder: (context, state) => const PublicationSearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _authorsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.authors,
                builder: (context, state) => const TopAuthorsScreen(),
                routes: [
                  GoRoute(
                    path: ':authorId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final authorId = state.pathParameters['authorId'] ?? '';
                      final topic = state.uri.queryParameters['topic'] ?? '';
                      return AuthorDetailScreen(
                        authorId: authorId,
                        topic: topic,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _journalsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.journals,
                builder: (context, state) => const LeadingJournalsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.publicationDetail}/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PublicationDetailScreen(publicationId: id);
        },
      ),
      GoRoute(
        path: '${AppRoutes.dashboard}/:keyword',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final keyword = state.pathParameters['keyword'] ?? '__ALL__';
          return ResearchDashboardScreen(keyword: keyword);
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Không tìm thấy trang: ${state.uri.toString()}'),
      ),
    ),
  );
});
