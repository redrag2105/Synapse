import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/presentation/screens/home/home_screen.dart';
import 'package:synapse/presentation/screens/publication_detail/publication_detail_screen.dart';
import 'package:synapse/presentation/screens/publication_search/publication_search_screen.dart';
import 'package:synapse/presentation/screens/research_dashboard/research_dashboard_screen.dart';
import 'package:synapse/presentation/screens/trend/trend_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String publicationDetail = '/detail';
  static const String trend = '/trend';
  static const String dashboard = '/dashboard';
  static const String topAuthors = '/top-authors';
  static const String topJournals = '/top-journals';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const PublicationSearchScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.publicationDetail}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PublicationDetailScreen(publicationId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.trend,
        builder: (context, state) => const TrendScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.dashboard}/:keyword',
        builder: (context, state) {
          final keyword = state.pathParameters['keyword'] ?? '__ALL__';
          return ResearchDashboardScreen(keyword: keyword);
        },
      ),
      GoRoute(
        path: AppRoutes.topAuthors,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Top Authors'),
      ),
      GoRoute(
        path: AppRoutes.topJournals,
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Top Journals'),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Không tìm thấy trang: ${state.uri.toString()}'),
      ),
    ),
  );
});

// =======================================================
// MÀN HÌNH TẠM THỜI (Sẽ xóa đi khi ta thiết kế UI thật)
// =======================================================
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Đây là màn hình: $title',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.search),
              child: const Text('Đi tới màn hình Tìm kiếm'),
            ),
          ],
        ),
      ),
    );
  }
}
