import 'package:synapse/domain/entities/journal_detail_entity.dart';

class JournalDetailModel extends JournalDetailEntity {
  const JournalDetailModel({
    required super.id,
    required super.displayName,
    super.issnL,
    super.issn,
    super.hostOrganizationName,
    super.isOa,
    super.isInDoaj,
    super.worksCount,
    super.citedByCount,
    super.twoYearMeanCitedness,
    super.hIndex,
    super.i10Index,
    super.apcUsd,
    super.homepageUrl,
    super.countsByYear,
    super.createdDate,
    super.updatedDate,
    super.wikidataId,
    super.openAlexUrl,
  });

  factory JournalDetailModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] as String? ?? '';
    final cleanId = rawId.contains('/') ? rawId.split('/').last : rawId;
    final summaryStats = json['summary_stats'] as Map<String, dynamic>?;
    final ids = json['ids'] as Map<String, dynamic>?;
    final issnList = (json['issn'] as List?)?.whereType<String>().toList() ?? [];

    final countsRaw = json['counts_by_year'] as List? ?? [];
    final countsByYear = countsRaw
        .whereType<Map<String, dynamic>>()
        .map(
          (entry) => JournalYearCount(
            year: entry['year'] as int? ?? 0,
            worksCount: entry['works_count'] as int? ?? 0,
            citedByCount: entry['cited_by_count'] as int? ?? 0,
          ),
        )
        .where((entry) => entry.year > 0)
        .toList()
      ..sort((a, b) => a.year.compareTo(b.year));

    return JournalDetailModel(
      id: cleanId,
      displayName: json['display_name'] as String? ?? 'Unknown Journal',
      issnL: json['issn_l'] as String?,
      issn: issnList,
      hostOrganizationName: json['host_organization_name'] as String?,
      isOa: json['is_oa'] as bool? ?? false,
      isInDoaj: json['is_in_doaj'] as bool? ?? false,
      worksCount: json['works_count'] as int? ?? 0,
      citedByCount: json['cited_by_count'] as int? ?? 0,
      twoYearMeanCitedness:
          (summaryStats?['2yr_mean_citedness'] as num?)?.toDouble() ?? 0,
      hIndex: summaryStats?['h_index'] as int? ?? 0,
      i10Index: summaryStats?['i10_index'] as int? ?? 0,
      apcUsd: json['apc_usd'] as int?,
      homepageUrl: json['homepage_url'] as String?,
      countsByYear: countsByYear,
      createdDate: json['created_date'] as String?,
      updatedDate: json['updated_date'] as String?,
      wikidataId: ids?['wikidata'] as String?,
      openAlexUrl: rawId.isNotEmpty ? rawId : null,
    );
  }
}
