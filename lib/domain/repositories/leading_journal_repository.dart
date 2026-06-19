import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/leading_journal_entity.dart';

abstract class LeadingJournalRepository {
  Future<Either<Failure, LeadingJournalsOverview>> getLeadingJournals();
}
