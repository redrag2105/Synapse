import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';

abstract class ParamUseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}
