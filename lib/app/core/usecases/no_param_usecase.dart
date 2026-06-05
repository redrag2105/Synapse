import 'package:fpdart/fpdart.dart';
import 'package:synapse/app/types/failure.dart';

abstract class NoParamUseCase<T> {
  Future<Either<Failure, T>> call();
}
