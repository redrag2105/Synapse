import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/domain/entities/leading_journal_entity.dart';
import 'package:synapse/presentation/screens/trend/widgets/metric_card.dart';

class JournalSummarySection extends StatelessWidget {
  final LeadingJournalInsights insights;
  final String activeJournalsSubtitle;

  const JournalSummarySection({
    super.key,
    required this.insights,
    this.activeJournalsSubtitle = 'tracked in dataset',
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        MetricCard(
          title: 'Active Journals',
          value: '${insights.activeJournals}',
          subtitle: activeJournalsSubtitle,
          icon: Icons.library_books,
          color: AppColors.brandBlue900,
        ),
        MetricCard(
          title: 'Most Prolific',
          value: AppFormatters.compactNumber(
            insights.mostProlificCount.toDouble(),
          ),
          subtitle: AppFormatters.stripParenthetical(
            insights.mostProlificJournal,
          ),
          icon: Icons.emoji_events,
          color: AppColors.brandBlue700,
        ),
        MetricCard(
          title: 'Highest Impact',
          value: insights.highestImpactHIndex.toStringAsFixed(0),
          subtitle: insights.highestImpactJournal,
          icon: Icons.auto_graph,
          color: AppColors.brandBlue600,
        ),
        MetricCard(
          title: 'Avg. Citations',
          value: AppFormatters.compactNumber(insights.avgCitations),
          subtitle: 'per journal',
          icon: Icons.format_quote,
          color: AppColors.brandBlue500,
        ),
      ],
    );
  }
}
