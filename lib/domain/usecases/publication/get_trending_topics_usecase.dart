import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/no_param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/topic_entity.dart';
import 'package:synapse/domain/repositories/publication_repository.dart';

class GetTrendingTopicsUseCase implements NoParamUseCase<List<TopicEntity>> {
  final PublicationRepository _repository;

  GetTrendingTopicsUseCase(this._repository);

  @override
  Future<Either<Failure, List<TopicEntity>>> call() async {
    return await _repository.getTrendingTopics();
  }
}
