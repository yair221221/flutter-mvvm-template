import 'package:dartz/dartz.dart';
import '../entities/friend.dart';
import '../repositories/friends_repository.dart';
import '../../core/error/failures.dart';

class GetFriendsUseCase {
  final FriendsRepository repository;
  const GetFriendsUseCase(this.repository);

  Future<Either<Failure, List<Friend>>> call() => repository.getFriends();
}
