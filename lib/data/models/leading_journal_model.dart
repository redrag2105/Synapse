import 'package:synapse/domain/entities/leading_journal_entity.dart';

class LeadingJournalModel extends LeadingJournalEntity {
  const LeadingJournalModel({
    required super.id,
    required super.name,
    required super.articleCount,
    required super.totalCitations,
    required super.hIndex,
    super.twoYearMeanCitedness,
  });

  factory LeadingJournalModel.fromOpenAlexJson(Map<String, dynamic> json) {
    final rawId = json['id'] as String? ?? '';
    final cleanId = rawId.contains('/') ? rawId.split('/').last : rawId;
    final summaryStats = json['summary_stats'] as Map<String, dynamic>?;

    return LeadingJournalModel(
      id: cleanId,
      name: json['display_name'] as String? ?? 'Unknown Journal',
      articleCount: json['works_count'] as int? ?? 0,
      totalCitations: json['cited_by_count'] as int? ?? 0,
      hIndex: (summaryStats?['h_index'] as num?)?.toDouble() ?? 0,
      twoYearMeanCitedness:
          (summaryStats?['2yr_mean_citedness'] as num?)?.toDouble() ?? 0,
    );
  }
}
