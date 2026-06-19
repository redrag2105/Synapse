class JournalQuartileDistribution {
  final double q1Percent;
  final double q2Percent;
  final double q3Percent;
  final double q4Percent;

  const JournalQuartileDistribution({
    required this.q1Percent,
    required this.q2Percent,
    required this.q3Percent,
    required this.q4Percent,
  });
}

class LeadingJournalEntity {
  final String id;
  final String name;
  final int articleCount;
  final int totalCitations;
  final double hIndex;
  final double twoYearMeanCitedness;

  const LeadingJournalEntity({
    required this.id,
    required this.name,
    required this.articleCount,
    required this.totalCitations,
    required this.hIndex,
    this.twoYearMeanCitedness = 0,
  });
}

class LeadingJournalInsights {
  final int activeJournals;
  final String mostProlificJournal;
  final int mostProlificCount;
  final String highestImpactJournal;
  final double highestImpactHIndex;
  final double avgCitations;

  const LeadingJournalInsights({
    required this.activeJournals,
    required this.mostProlificJournal,
    required this.mostProlificCount,
    required this.highestImpactJournal,
    required this.highestImpactHIndex,
    required this.avgCitations,
  });
}

class LeadingJournalsOverview {
  final List<LeadingJournalEntity> journals;
  final LeadingJournalInsights insights;
  final JournalQuartileDistribution quartileDistribution;

  const LeadingJournalsOverview({
    required this.journals,
    required this.insights,
    required this.quartileDistribution,
  });
}
