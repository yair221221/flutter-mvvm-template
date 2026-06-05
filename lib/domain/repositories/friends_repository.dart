import 'package:dartz/dartz.dart';
import '../entities/friend.dart';
import '../entities/friend_request.dart';
import '../entities/friend_suggestion.dart';
import '../../core/error/failures.dart';

abstract class FriendsRepository {
  Future<Either<Failure, List<Friend>>> getFriends();
  Future<Either<Failure, List<FriendRequest>>> getPendingRequests();
  Future<Either<Failure, List<FriendSuggestion>>> getSuggestions();
  Future<Either<Failure, void>> acceptRequest(String id);
  Future<Either<Failure, void>> declineRequest(String id);
  Future<Either<Failure, String>> generateInviteText();
}
