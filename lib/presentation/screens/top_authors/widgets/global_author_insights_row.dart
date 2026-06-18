import 'package:flutter/cupertino.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/domain/entities/global_author_insights_entity.dart';
import 'package:synapse/presentation/screens/trend/widgets/metric_card.dart';

class GlobalAuthorInsightsRow extends StatelessWidget {
  final GlobalAuthorInsights insights;

  const GlobalAuthorInsightsRow({super.key, required this.insights});

  String _trendSubtitle(double trend) {
    final direction = trend >= 0 ? 'growth' : 'decline';
    final sign = trend >= 0 ? '+' : '';
    return '$sign${trend.toStringAsFixed(1)}% $direction';
  }

  Color _trendColor(double trend) {
    if (trend > 0) return AppColors.success;
    if (trend < 0) return AppColors.error;
    return AppColors.textLight;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Co-Authorship Density',
                    value: '${insights.coAuthorshipDensity.toStringAsFixed(1)}%',
                    subtitle: _trendSubtitle(insights.coAuthorshipTrend),
                    subtitleColor: _trendColor(insights.coAuthorshipTrend),
                    icon: CupertinoIcons.person_2_fill,
                    color: AppColors.brandBlue900,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: 'Global Impact Score',
                    value: insights.globalImpactScore.toStringAsFixed(1),
                    subtitle: _trendSubtitle(insights.globalImpactTrend),
                    subtitleColor: _trendColor(insights.globalImpactTrend),
                    icon: CupertinoIcons.chart_bar_alt_fill,
                    color: AppColors.brandBlue700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Int. Collaboration',
                    value: AppFormatters.formatNumber(insights.intCollaboration),
                    subtitle: _trendSubtitle(insights.intCollaborationTrend),
                    subtitleColor: _trendColor(insights.intCollaborationTrend),
                    icon: CupertinoIcons.globe,
                    color: AppColors.brandBlue600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    title: 'Active ORCIDs',
                    value: AppFormatters.formatNumber(insights.activeOrcids),
                    subtitle: 'verified researchers',
                    icon: CupertinoIcons.rosette,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
