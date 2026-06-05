import 'package:synapse/domain/entities/journal_entity.dart';

class JournalModel extends JournalEntity {
  const JournalModel({
    required super.id,
    required super.displayName,
    super.worksCount,
    super.citedByCount,
    super.hIndex,
    super.i10Index,
  });

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    final summaryStats = json['summary_stats'] as Map<String, dynamic>?;
    final hIndex = summaryStats?['h_index'] as int? ?? 0;
    final i10Index = summaryStats?['i10_index'] as int? ?? 0;

    return JournalModel(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? 'Unknown Journal',
      worksCount: json['works_count'] as int? ?? 0,
      citedByCount: json['cited_by_count'] as int? ?? 0,
      hIndex: hIndex,
      i10Index: i10Index,
    );
  }
}
