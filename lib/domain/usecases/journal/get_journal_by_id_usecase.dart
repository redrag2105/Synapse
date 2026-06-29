import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/journal_detail_entity.dart';
import 'package:synapse/domain/repositories/journal_repository.dart';

class GetJournalByIdUseCase
    implements ParamUseCase<JournalDetailEntity, String> {
  final JournalRepository _repository;

  GetJournalByIdUseCase(this._repository);

  @override
  Future<Either<Failure, JournalDetailEntity>> call(String journalId) {
    return _repository.getJournalById(journalId);
  }
}
