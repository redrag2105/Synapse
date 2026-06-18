class AuthorEntity {
  final String id;
  final String displayName;
  final String? orcid;
  final int worksCount;
  final int citedByCount;
  final int hIndex;
  final int i10Index;
  final String? lastKnownInstitutionName;
  final String? lastKnownInstitutionCountry;
  final List<AuthorResearchTopic> researchTopics;

  const AuthorEntity({
    required this.id,
    required this.displayName,
    this.orcid,
    this.worksCount = 0,
    this.citedByCount = 0,
    this.hIndex = 0,
    this.i10Index = 0,
    this.lastKnownInstitutionName,
    this.lastKnownInstitutionCountry,
    this.researchTopics = const [],
  });
}

class AuthorResearchTopic {
  final String id;
  final String displayName;
  final int count;

  const AuthorResearchTopic({
    required this.id,
    required this.displayName,
    required this.count,
  });
}
