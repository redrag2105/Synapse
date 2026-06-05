import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/core/usecases/param_usecase.dart';
import 'package:synapse/app/types/failure.dart';
import 'package:synapse/domain/entities/topic_entity.dart';
import 'package:synapse/domain/repositories/topic_repository.dart';

class GetTopicHintsUseCase implements ParamUseCase<List<TopicEntity>, String> {
  final TopicRepository _repository;
  GetTopicHintsUseCase(this._repository);

  @override
  Future<Either<Failure, List<TopicEntity>>> call(String keyword) async {
    return await _repository.getTopicHints(keyword);
  }
}
