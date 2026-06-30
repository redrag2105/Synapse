import 'package:synapse/domain/entities/journal_entity.dart';

class TopJournalsPage {
  final List<JournalEntity> journals;
  final int totalCount;
  final String? topicId;

  const TopJournalsPage({
    required this.journals,
    required this.totalCount,
    this.topicId,
  });
}
