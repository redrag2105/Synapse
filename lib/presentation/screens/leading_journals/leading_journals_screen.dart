import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/domain/entities/leading_journal_entity.dart';
import 'package:synapse/presentation/controllers/leading_journals_controller.dart';
import 'package:synapse/presentation/screens/leading_journals/widgets/journal_leaderboard.dart';
import 'package:synapse/presentation/screens/leading_journals/widgets/journal_quartile_distribution_chart.dart';
import 'package:synapse/presentation/screens/leading_journals/widgets/journal_summary_section.dart';
import 'package:synapse/presentation/screens/leading_journals/widgets/journal_top_bar_chart.dart';
import 'package:synapse/presentation/screens/leading_journals/widgets/leading_journals_skeleton.dart';

class LeadingJournalsScreen extends ConsumerWidget {
  const LeadingJournalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leadingJournalsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceGray,
      appBar: AppBar(
        title: Text(
          'Leading Journals',
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.brandBlue900,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: state.when(
          loading: () => const LeadingJournalsSkeleton(
            key: ValueKey('leading_journals_loading'),
          ),
          error: (error, _) => _buildErrorState(context, ref, error),
          data: (overview) => _buildContent(
            key: const ValueKey('leading_journals_data'),
            overview: overview,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      key: const ValueKey('leading_journals_error'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text('Lỗi: $error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(leadingJournalsControllerProvider.notifier).reload(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent({
    required Key key,
    required LeadingJournalsOverview overview,
  }) {
    return SingleChildScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Overview'),
          const SizedBox(height: 12),
          JournalSummarySection(insights: overview.insights),
          const SizedBox(height: 24),
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
          const SizedBox(height: 24),
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
