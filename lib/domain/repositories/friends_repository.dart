import 'package:dartz/dartz.dart';
import '../entities/friend.dart';
import '../entities/friend_request.dart';
import '../entities/friend_suggestion.dart';
import '../../core/error/failures.dart';

abstract class FriendsRepository {
  // ── One-shot reads ─────────────────────────────────────────────────────────
  Future<Either<Failure, List<Friend>>> getFriends();
  Future<Either<Failure, List<FriendRequest>>> getPendingRequests();
  Future<Either<Failure, List<FriendSuggestion>>> getSuggestions();
  Future<Either<Failure, void>> acceptRequest(String id);
  Future<Either<Failure, void>> declineRequest(String id);
  Future<Either<Failure, String>> generateInviteText();

  // ── Real-time streams (Firebase overrides; mock wraps the Future methods) ──
  //
  // The default implementations wrap the one-shot Future calls so the mock
  // repository gets stream behaviour for free. Firebase repository overrides
  // these with native Firestore .snapshots() streams for sub-second updates.

  Stream<List<Friend>> streamFriends() => Stream.fromFuture(
        getFriends().then((e) => e.fold((_) => [], (v) => v)),
      );

  Stream<List<FriendRequest>> streamRequests() => Stream.fromFuture(
        getPendingRequests().then((e) => e.fold((_) => [], (v) => v)),
      );
}
