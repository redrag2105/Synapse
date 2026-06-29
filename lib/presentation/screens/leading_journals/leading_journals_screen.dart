import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/domain/entities/leading_journal_entity.dart';
import 'package:synapse/presentation/controllers/leading_journals_controller.dart';
import 'package:synapse/presentation/controllers/tab_bar_ui_controller.dart';
import 'package:synapse/presentation/screens/leading_journals/widgets/journal_leaderboard.dart';
import 'package:synapse/presentation/screens/leading_journals/widgets/journal_quartile_distribution_chart.dart';
import 'package:synapse/presentation/screens/leading_journals/widgets/journal_summary_section.dart';
import 'package:synapse/presentation/screens/leading_journals/widgets/journal_top_bar_chart.dart';
import 'package:synapse/presentation/screens/leading_journals/widgets/leading_journals_skeleton.dart';
import 'package:synapse/presentation/utils/shell_keyword_intent_listener.dart';
import 'package:synapse/presentation/widgets/universal_header_delegate.dart';
import 'package:synapse/presentation/widgets/navigation/app_bottom_nav_layout.dart';
import 'package:synapse/presentation/widgets/navigation/tab_screen_scaffold.dart';

class LeadingJournalsScreen extends ConsumerStatefulWidget {
  const LeadingJournalsScreen({super.key});

  @override
  ConsumerState<LeadingJournalsScreen> createState() =>
      _LeadingJournalsScreenState();
}

class _LeadingJournalsScreenState extends ConsumerState<LeadingJournalsScreen>
    with SingleTickerProviderStateMixin {
  static const String _globalSubtitle = 'Top sources by citation impact';

  late final AnimationController _focusAnimController;
  String _currentSubtitle = _globalSubtitle;
  bool _isSearchBarFocused = false;

  @override
  void initState() {
    super.initState();
    _focusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduleShellKeywordIntentConsumption(
        ref: ref,
        tabIndex: ShellTabIndex.journals,
        onKeyword: _applyKeyword,
      );
      if (ref.read(shellKeywordIntentProvider) != null) return;

      final notifier = ref.read(leadingJournalsControllerProvider.notifier);
      final lastQuery = notifier.lastQuery;
      notifier.fetch(lastQuery);
    });
  }

  @override
  void dispose() {
    ref.read(tabBarSuppressedProvider.notifier).setSuppressed(false);
    _focusAnimController.dispose();
    super.dispose();
  }

  void _applyKeyword(String keyword) {
    final query = keyword.trim();
    final isGlobal = query.isEmpty;

    setState(() {
      _currentSubtitle = isGlobal ? _globalSubtitle : query;
      _isSearchBarFocused = false;
    });

    _focusAnimController.reverse();
    FocusManager.instance.primaryFocus?.unfocus();

    ref
        .read(leadingJournalsControllerProvider.notifier)
        .fetch(isGlobal ? '' : query, forceRefresh: true);
  }

  void _onFocusChanged(bool hasFocus) {
    _isSearchBarFocused = hasFocus;
    updateTabBarSuppressed(ref, hasFocus);
    if (hasFocus) {
      _focusAnimController.forward();
    } else {
      _focusAnimController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    bindShellKeywordIntent(
      ref: ref,
      tabIndex: ShellTabIndex.journals,
      onKeyword: _applyKeyword,
    );

    final state = ref.watch(leadingJournalsControllerProvider);
    final topPadding = MediaQuery.paddingOf(context).top;
    final isGlobal = _currentSubtitle == _globalSubtitle;
    final initialSearchQuery = isGlobal ? '' : _currentSubtitle;

    return TabScreenScaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              AnimatedBuilder(
                animation: _focusAnimController,
                builder: (context, child) {
                  return SliverPersistentHeader(
                    pinned: true,
                    delegate: UniversalHeaderDelegate(
                      showBackButton: false,
                      topPadding: topPadding,
                      title: 'Leading Journals',
                      subtitle: _currentSubtitle,
                      searchBarInitialValue: initialSearchQuery,
                      searchBarHintText: 'Search for a research topic...',
                      focusProgress: _focusAnimController.value,
                      onFocusChanged: _onFocusChanged,
                      onSubmitted: _applyKeyword,
                      onTopicSelected: (topic) {
                        _applyKeyword(topic.displayName);
                      },
                    ),
                  );
                },
              ),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: state.when(
                    loading: () => const LeadingJournalsSkeleton(
                      key: ValueKey('leading_journals_loading'),
                    ),
                    error: (error, _) => _buildErrorState(error),
                    data: (overview) {
                      if (overview.journals.isEmpty) {
                        return _buildEmptyState(
                          key: const ValueKey('leading_journals_empty'),
                        );
                      }
                      return _buildContent(
                        key: const ValueKey('leading_journals_data'),
                        overview: overview,
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: TabBarContentPadding()),
            ],
          ),
          AnimatedBuilder(
            animation: _focusAnimController,
            builder: (context, child) {
              final focusProgress = _focusAnimController.value;

              if (!_isSearchBarFocused && focusProgress == 0.0) {
                return const SizedBox.shrink();
              }

              return Positioned(
                top: (topPadding + 160.0) - (95.0 * focusProgress),
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: Opacity(
                    opacity: focusProgress,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Padding(
      key: const ValueKey('leading_journals_error'),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text('Error: $error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                ref.read(leadingJournalsControllerProvider.notifier).reload(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required Key key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          'No journals found for this topic.',
          style: AppTextStyles.metadata,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContent({
    required Key key,
    required LeadingJournalsOverview overview,
  }) {
    return Padding(
      key: key,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Overview'),
          JournalSummarySection(
            insights: overview.insights,
            activeJournalsSubtitle:
                ref
                    .read(leadingJournalsControllerProvider.notifier)
                    .isGlobalView
                ? 'tracked in dataset'
                : 'matching this topic',
          ),
          const SizedBox(height: 18),
          JournalQuartileDistributionChart(
            distribution: overview.quartileDistribution,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Journal Rankings'),
          const SizedBox(height: 12),
          JournalTopBarChart(journals: overview.journals),
          const SizedBox(height: 24),
          _buildSectionTitle('Detailed Leaderboard'),
          const SizedBox(height: 12),
          JournalLeaderboard(journals: overview.journals),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h3.copyWith(
        fontSize: 16,
        color: AppColors.brandBlue900,
      ),
    );
  }
}
