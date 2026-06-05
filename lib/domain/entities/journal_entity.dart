class JournalEntity {
  final String id;
  final String displayName;
  final int worksCount;
  final int citedByCount;
  final int hIndex;
  final int i10Index;

  const JournalEntity({
    required this.id,
    required this.displayName,
    this.worksCount = 0,
    this.citedByCount = 0,
    this.hIndex = 0,
    this.i10Index = 0,
  });
}
