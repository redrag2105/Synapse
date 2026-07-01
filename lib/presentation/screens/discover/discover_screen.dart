import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/config/routes/app_routes.dart';
import 'package:synapse/domain/entities/keyword_entity.dart';
import 'package:synapse/presentation/controllers/auth_providers.dart';
import 'package:synapse/presentation/controllers/most_frequent_keywords_controller.dart';
import 'package:synapse/presentation/controllers/trending_keywords_controller.dart';
import 'package:synapse/presentation/screens/discover/utils/keyword_navigation.dart';
import 'package:synapse/presentation/screens/discover/widgets/discover_header_delegate.dart';
import 'package:synapse/presentation/screens/discover/widgets/keyword_chip.dart';
import 'package:synapse/presentation/screens/discover/widgets/keyword_frequency_chart.dart';
import 'package:synapse/presentation/screens/discover/widgets/keyword_stats_overview.dart';
import 'package:synapse/presentation/widgets/navigation/app_bottom_nav_layout.dart';
import 'package:synapse/app/config/test_keys.dart';
import 'package:synapse/presentation/widgets/navigation/tab_screen_scaffold.dart';

/// Home tab — keyword discovery and analysis.
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final currentYear = DateTime.now().year;

    final frequentState = ref.watch(mostFrequentKeywordsControllerProvider);
    final trendingState = ref.watch(trendingKeywordsControllerProvider);
    final user = ref.watch(currentUserProvider);

    final topKeyword = frequentState.maybeWhen(
      data: (list) => list.isNotEmpty ? list.first : null,
      orElse: () => null,
    );
    final trendingCount = trendingState.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );
    final frequentCount = frequentState.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );
    final statsLoading = frequentState.isLoading && !frequentState.hasValue;

    void onKeywordTap(KeywordEntity keyword) {
      openKeywordInSearch(context, ref, keyword);
    }

    return TabScreenScaffold(
      key: TestKeys.discoverScreen,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: DiscoverHeaderDelegate(
              topPadding: topPadding,
              onProfileTap: () => context.push(AppRoutes.profile),
              isSignedIn: user != null,
              profilePhotoUrl: user?.photoURL,
              profileDisplayName: user?.displayName,
              profileEmail: user?.email,
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keywords',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.brandBlue900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Keyword-based research analysis across scholarly literature.',
                    style: AppTextStyles.metadata.copyWith(
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  KeywordStatsOverview(
                    topKeyword: topKeyword,
                    trendingCount: trendingCount,
                    frequentCount: frequentCount,
                    isLoading: statsLoading,
                    onTopKeywordTap: topKeyword != null
                        ? () => onKeywordTap(topKeyword)
                        : null,
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Most Frequent Keywords',
                subtitle: 'Top keywords by publication volume (all time)',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: frequentState.when(
                  loading: () => const KeywordFrequencySkeleton(
                    key: ValueKey('frequent_loading'),
                  ),
                  error: (_, _) => _SectionError(
                    key: const ValueKey('frequent_error'),
                    message: 'Unable to load frequent keywords.',
                  ),
                  data: (keywords) => KeywordFrequencyChart(
                    key: const ValueKey('frequent_data'),
                    keywords: keywords,
                    onKeywordTap: onKeywordTap,
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Trending Keywords',
                subtitle: 'Rising keywords (${currentYear - 2} - $currentYear)',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      ...previousChildren,
                      ?currentChild,
                    ],
                  );
                },
                child: trendingState.when(
                  loading: () => Wrap(
                    key: const ValueKey('trending_loading'),
                    alignment: WrapAlignment.start,
                    spacing: 10,
                    runSpacing: 12,
                    children: const [
                      KeywordChipSkeleton(width: 120),
                      KeywordChipSkeleton(width: 160),
                      KeywordChipSkeleton(width: 100),
                      KeywordChipSkeleton(width: 140),
                    ],
                  ),
                  error: (_, _) => _SectionError(
                    key: const ValueKey('trending_error'),
                    message: 'Unable to load trending keywords.',
                  ),
                  data: (keywords) {
                    if (keywords.isEmpty) {
                      return const SizedBox.shrink(
                        key: ValueKey('trending_empty'),
                      );
                    }
                    return Wrap(
                      key: const ValueKey('trending_data'),
                      alignment: WrapAlignment.start,
                      spacing: 10,
                      runSpacing: 12,
                      children: keywords
                          .map(
                            (k) => KeywordChip(
                              keyword: k,
                              showCount: true,
                              onTap: () => onKeywordTap(k),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: TabBarContentPadding()),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTextStyles.metadata.copyWith(fontSize: 12)),
      ],
    );
  }
}

class _SectionError extends StatelessWidget {
  final String message;

  const _SectionError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(message, style: AppTextStyles.metadata);
  }
}
