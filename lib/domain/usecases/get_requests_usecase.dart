import 'package:dartz/dartz.dart';
import '../entities/friend_request.dart';
import '../repositories/friends_repository.dart';
import '../../core/error/failures.dart';

class GetRequestsUseCase {
  final FriendsRepository repository;
  const GetRequestsUseCase(this.repository);

  Future<Either<Failure, List<FriendRequest>>> call() =>
      repository.getPendingRequests();
}
