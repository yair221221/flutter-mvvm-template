import 'package:dartz/dartz.dart';
import '../repositories/friends_repository.dart';
import '../../core/error/failures.dart';

class DeclineRequestUseCase {
  final FriendsRepository repository;
  const DeclineRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) =>
      repository.declineRequest(id);
}
