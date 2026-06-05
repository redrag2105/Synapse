import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/publication_entity.dart';
import 'package:synapse/domain/repositories/publication_repository.dart';

class GetPublicationByIdUseCase {
  final PublicationRepository _repository;

  GetPublicationByIdUseCase(this._repository);

  Future<Either<Failure, PublicationEntity>> call(String id) async {
    return await _repository.getPublicationById(id);
  }
}
