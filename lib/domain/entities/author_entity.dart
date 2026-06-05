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
  });
}
