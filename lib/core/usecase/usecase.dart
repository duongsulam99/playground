import 'package:dartz/dartz.dart';
import 'package:vulcan_mobile_playground/core/error/failure.dart';

abstract class Usecase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

abstract class StreamUsecase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}

class NoParams {
  const NoParams();
}
