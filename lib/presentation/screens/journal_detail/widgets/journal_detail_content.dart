import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:synapse/app/config/app_colors.dart';
import 'package:synapse/app/config/app_text_styles.dart';
import 'package:synapse/app/utils/app_formatters.dart';
import 'package:synapse/app/utils/url_helper.dart';
import 'package:synapse/domain/entities/journal_detail_entity.dart';
import 'package:synapse/presentation/screens/journal_detail/widgets/journal_activity_chart.dart';
import 'package:synapse/presentation/screens/trend/widgets/metric_card.dart';

class JournalDetailContent extends StatelessWidget {
  final JournalDetailEntity journal;

  const JournalDetailContent({super.key, required this.journal});

  @override
  Widget build(BuildContext context) {
    final issnValues = {
      if (journal.issnL != null && journal.issnL!.isNotEmpty) journal.issnL!,
      ...journal.issn,
    }.toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              MetricCard(
                title: '2yr Citedness',
                value: journal.twoYearMeanCitedness > 0
                    ? journal.twoYearMeanCitedness.toStringAsFixed(2)
                    : '—',
                subtitle: 'mean impact',
                icon: Icons.auto_graph_outlined,
                color: AppColors.brandBlue700,
              ),
              MetricCard(
                title: 'i10-Index',
                value: '${journal.i10Index}',
                subtitle: '10+ citation papers',
                icon: Icons.insights_outlined,
                color: AppColors.brandBlue600,
              ),
              MetricCard(
                title: 'APC',
                value: journal.apcUsd != null && journal.apcUsd! > 0
                    ? '\$${AppFormatters.formatNumber(journal.apcUsd!)}'
                    : '—',
                subtitle: 'article processing',
                icon: Icons.payments_outlined,
                color: AppColors.brandBlue500,
              ),
              MetricCard(
                title: 'Access',
                value: journal.isOa ? 'Open' : 'Closed',
                subtitle: journal.isInDoaj ? 'DOAJ listed' : 'access model',
                icon: Icons.lock_open_outlined,
                color: journal.isOa ? AppColors.success : AppColors.textLight,
                subtitleColor:
                    journal.isOa ? AppColors.success : AppColors.textLight,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Impact Details',
            children: [
              _InfoRow(
                label: '2-Year Mean Citedness',
                value: journal.twoYearMeanCitedness > 0
                    ? journal.twoYearMeanCitedness.toStringAsFixed(2)
                    : '—',
              ),
              _InfoRow(
                label: 'Article Processing Charge',
                value: journal.apcUsd != null && journal.apcUsd! > 0
                    ? '\$${AppFormatters.formatNumber(journal.apcUsd!)}'
                    : 'Not listed',
              ),
            ],
          ),
          if (issnValues.isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoCard(
              title: 'ISSN',
              children: issnValues
                  .map((issn) => _InfoRow(label: 'ISSN', value: issn))
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          JournalActivityChart(countsByYear: journal.countsByYear),
          if (journal.homepageUrl != null &&
              journal.homepageUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _LinkCard(
              label: 'Journal Homepage',
              url: journal.homepageUrl!,
            ),
          ],
          if (journal.openAlexUrl != null) ...[
            const SizedBox(height: 12),
            _LinkCard(
              label: 'View on OpenAlex',
              url: journal.openAlexUrl!.startsWith('http')
                  ? journal.openAlexUrl!
                  : 'https://openalex.org/${journal.id}',
            ),
          ],
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Record Metadata',
            children: [
              if (journal.wikidataId != null)
                _InfoRow(label: 'Wikidata', value: journal.wikidataId!),
              _InfoRow(label: 'OpenAlex ID', value: journal.id),
              if (journal.createdDate != null)
                _InfoRow(label: 'Created', value: journal.createdDate!),
              if (journal.updatedDate != null)
                _InfoRow(
                  label: 'Last Updated',
                  value: _formatUpdatedDate(journal.updatedDate!),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _formatUpdatedDate(String raw) {
    if (raw.length >= 10) return raw.substring(0, 10);
    return raw;
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              fontSize: 15,
              color: AppColors.brandBlue900,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: AppTextStyles.metadata.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.metadata.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final String label;
  final String url;

  const _LinkCard({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => UrlHelper.launch(url),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.link,
                size: 18,
                color: AppColors.brandBlue700,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    color: AppColors.brandBlue900,
                  ),
                ),
              ),
              const Icon(
                CupertinoIcons.arrow_up_right,
                size: 16,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
