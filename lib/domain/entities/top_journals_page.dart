import 'package:synapse/domain/entities/journal_entity.dart';

class TopJournalsPage {
  final List<JournalEntity> journals;
  final int totalCount;

  const TopJournalsPage({
    required this.journals,
    required this.totalCount,
  });
}
