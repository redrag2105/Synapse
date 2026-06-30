import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/app/types/paginated_list_state.dart';
import 'package:synapse/domain/entities/publication_entity.dart';
import 'package:synapse/domain/repositories/publication_repository.dart';

class GetJournalPublicationsParams {
  final String journalId;
  final int page;
  final int limit;

  GetJournalPublicationsParams({
    required this.journalId,
    this.page = 1,
    this.limit = PaginatedListState.defaultPageSize,
  });
}

class GetJournalPublicationsUseCase
    implements
        ParamUseCase<List<PublicationEntity>, GetJournalPublicationsParams> {
  final PublicationRepository _repository;

  GetJournalPublicationsUseCase(this._repository);

  @override
  Future<Either<Failure, List<PublicationEntity>>> call(
    GetJournalPublicationsParams params,
  ) {
    return _repository.getPublicationsByJournalId(
      params.journalId,
      page: params.page,
      limit: params.limit,
    );
  }
}
