import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/config/test_keys.dart';
import 'package:synapse/domain/entities/keyword_entity.dart';
import 'package:synapse/presentation/controllers/trending_keywords_controller.dart';
import 'package:synapse/presentation/controllers/user_frequent_keywords_controller.dart';
import 'package:synapse/presentation/screens/discover/utils/keyword_navigation.dart';
import 'package:synapse/presentation/screens/discover/widgets/keyword_chip.dart';
import 'package:synapse/presentation/screens/discover/widgets/keyword_frequency_chart.dart';
import 'package:synapse/presentation/screens/discover/widgets/keyword_stats_overview.dart';
import 'package:synapse/presentation/screens/keywords/widgets/keywords_header_delegate.dart';
import 'package:synapse/presentation/widgets/navigation/app_bottom_nav_layout.dart';
import 'package:synapse/presentation/widgets/navigation/tab_screen_scaffold.dart';

/// Keywords tab — personalized from signed-in search history + global trending.
class KeywordsScreen extends ConsumerWidget {
  const KeywordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final currentYear = DateTime.now().year;

    final userFrequentState = ref.watch(userFrequentKeywordsProvider);
    final trendingState = ref.watch(trendingKeywordsControllerProvider);

    final topKeyword = userFrequentState.maybeWhen(
      data: (state) => state.topKeyword,
      orElse: () => null,
    );
    final trendingCount = trendingState.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );
    final frequentCount = userFrequentState.maybeWhen(
      data: (state) => state.displayCount,
      orElse: () => 0,
    );
    final statsLoading =
        userFrequentState.isLoading && !userFrequentState.hasValue;

    final emptyTopLabel = userFrequentState.maybeWhen(
      data: (state) => state.isSignedIn
          ? 'Search topics on Home to personalize'
          : 'Sign in to track your top keyword',
      orElse: () => 'Search topics on Home to personalize',
    );

    void onKeywordTap(KeywordEntity keyword) {
      openKeywordDetail(context, keyword);
    }

    return TabScreenScaffold(
      key: TestKeys.keywordsScreen,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: KeywordsHeaderDelegate(topPadding: topPadding),
          ),
          _SpacedPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.brandBlue900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your search history plus rising themes across scholarly literature.',
                  style: AppTextStyles.metadata.copyWith(
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                KeywordStatsOverview(
                  topKeyword: topKeyword,
                  topKeywordSearchCount: userFrequentState.maybeWhen(
                    data: (state) => state.topSearchCount,
                    orElse: () => 0,
                  ),
                  trendingCount: trendingCount,
                  frequentCount: frequentCount,
                  isLoading: statsLoading,
                  emptyTopLabel: emptyTopLabel,
                  onTopKeywordTap: topKeyword != null
                      ? () => onKeywordTap(topKeyword)
                      : null,
                ),
              ],
            ),
          ),
          _SpacedPadding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
            child: _SectionHeader(
              title: 'Most Frequent Keywords',
              subtitle: 'Your most searched topics (with publication volume)',
            ),
          ),
          _SpacedPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: userFrequentState.when(
                loading: () => const KeywordFrequencySkeleton(
                  key: ValueKey('frequent_loading'),
                ),
                error: (_, _) => _SectionError(
                  key: const ValueKey('frequent_error'),
                  message: 'Unable to load your frequent keywords.',
                ),
                data: (state) {
                  if (state.isEmpty) {
                    return _FrequentEmptyState(
                      key: TestKeys.keywordsFrequentEmpty,
                      isSignedIn: state.isSignedIn,
                    );
                  }
                  return KeywordFrequencyChart(
                    key: const ValueKey('frequent_data'),
                    keywords: state.keywords,
                    onKeywordTap: onKeywordTap,
                  );
                },
              ),
            ),
          ),
          _SpacedPadding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
            child: _SectionHeader(
              title: 'Trending Keywords',
              subtitle: 'Rising keywords (${currentYear - 2} - $currentYear)',
            ),
          ),
          _SpacedPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
          const SliverToBoxAdapter(child: TabBarContentPadding()),
        ],
      ),
    );
  }
}

class _FrequentEmptyState extends StatelessWidget {
  final bool isSignedIn;

  const _FrequentEmptyState({super.key, required this.isSignedIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Text(
        isSignedIn
            ? 'Search research topics on Home — your most frequent keywords will appear here.'
            : 'Sign in and search topics on Home to build your personal keyword list.',
        style: AppTextStyles.metadata.copyWith(
          fontSize: 13,
          height: 1.45,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SpacedPadding extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _SpacedPadding({
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverToBoxAdapter(child: child),
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
