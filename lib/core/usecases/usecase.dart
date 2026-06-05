import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base class for all use cases.
/// [Type] is the return type, [Params] is the input parameter type.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this when a use case takes no parameters.
class NoParams {}
