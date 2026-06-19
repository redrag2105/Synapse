import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/no_param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/leading_journal_entity.dart';
import 'package:synapse/domain/repositories/leading_journal_repository.dart';

class GetLeadingJournalsUseCase implements NoParamUseCase<LeadingJournalsOverview> {
  final LeadingJournalRepository _repository;

  GetLeadingJournalsUseCase(this._repository);

  @override
  Future<Either<Failure, LeadingJournalsOverview>> call() {
    return _repository.getLeadingJournals();
  }
}
