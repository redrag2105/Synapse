import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/presentation/screens/author_detail/author_detail_screen.dart';
import 'package:synapse/presentation/screens/home/home_screen.dart';
import 'package:synapse/presentation/screens/journal_detail/journal_detail_screen.dart';
import 'package:synapse/presentation/screens/keywords/keywords_screen.dart';
import 'package:synapse/presentation/screens/leading_journals/leading_journals_screen.dart';
import 'package:synapse/presentation/screens/profile/profile_screen.dart';
import 'package:synapse/presentation/screens/publication_detail/publication_detail_screen.dart';
import 'package:synapse/presentation/screens/research_dashboard/research_dashboard_screen.dart';
import 'package:synapse/presentation/screens/trend/trend_screen.dart';
import 'package:synapse/presentation/screens/top_authors/top_authors_screen.dart';
import 'package:synapse/presentation/shell/app_shell_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String homeTab = '/home';
  static const String keywords = '/keywords';
  static const String publicationDetail = '/detail';
  static const String trend = '/trend';
  static const String dashboard = '/dashboard';
  static const String authors = '/authors';
  static const String journals = '/journals';
  static const String profile = '/profile';

  // Legacy path aliases kept for deep links / redirects.
  static const String discover = '/discover';
  static const String search = '/search';

  static String journalDetail(String journalId) =>
      '$journals/${Uri.encodeComponent(journalId)}';

  /// Keyword Detail — research analytics for a single keyword.
  static String keywordDetail(String keyword) =>
      '$dashboard/${Uri.encodeComponent(keyword)}';

  // Legacy aliases kept for existing deep links / references.
  static const String topAuthors = authors;
  static const String topJournals = journals;
}

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _keywordsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'keywords');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _authorsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'authors');
final _journalsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'journals');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.homeTab,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final path = state.uri.path;
      if (path == AppRoutes.home || path == AppRoutes.search) {
        return AppRoutes.homeTab;
      }
      if (path == AppRoutes.discover) return AppRoutes.keywords;
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _keywordsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.keywords,
                builder: (context, state) => const KeywordsScreen(),
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
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.homeTab,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _journalsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.journals,
                builder: (context, state) => const LeadingJournalsScreen(),
                routes: [
                  GoRoute(
                    path: ':journalId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final journalId = state.pathParameters['journalId'] ?? '';
                      return JournalDetailScreen(journalId: journalId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
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
        path: AppRoutes.trend,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final keyword = state.uri.queryParameters['keyword'];
          return TrendScreen(topicName: keyword);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Không tìm thấy trang: ${state.uri.toString()}'),
      ),
    ),
  );
});
