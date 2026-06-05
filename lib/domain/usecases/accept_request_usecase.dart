import 'package:dartz/dartz.dart';
import '../repositories/friends_repository.dart';
import '../../core/error/failures.dart';

class AcceptRequestUseCase {
  final FriendsRepository repository;
  const AcceptRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) => repository.acceptRequest(id);
}
