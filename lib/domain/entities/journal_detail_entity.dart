class JournalYearCount {
  final int year;
  final int worksCount;
  final int citedByCount;

  const JournalYearCount({
    required this.year,
    required this.worksCount,
    required this.citedByCount,
  });
}

class JournalDetailEntity {
  final String id;
  final String displayName;
  final String? issnL;
  final List<String> issn;
  final String? hostOrganizationName;
  final bool isOa;
  final bool isInDoaj;
  final int worksCount;
  final int citedByCount;
  final double twoYearMeanCitedness;
  final int hIndex;
  final int i10Index;
  final int? apcUsd;
  final String? homepageUrl;
  final List<JournalYearCount> countsByYear;
  final String? createdDate;
  final String? updatedDate;
  final String? wikidataId;
  final String? openAlexUrl;

  const JournalDetailEntity({
    required this.id,
    required this.displayName,
    this.issnL,
    this.issn = const [],
    this.hostOrganizationName,
    this.isOa = false,
    this.isInDoaj = false,
    this.worksCount = 0,
    this.citedByCount = 0,
    this.twoYearMeanCitedness = 0,
    this.hIndex = 0,
    this.i10Index = 0,
    this.apcUsd,
    this.homepageUrl,
    this.countsByYear = const [],
    this.createdDate,
    this.updatedDate,
    this.wikidataId,
    this.openAlexUrl,
  });
}
