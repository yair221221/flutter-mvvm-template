import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friend_request.dart';
import '../../domain/entities/friend_suggestion.dart';
import '../../domain/repositories/friends_repository.dart';

/// Real-time Firestore implementation of [FriendsRepository].
///
/// ## Firestore structure
/// ```
/// /users/{uid}
///   displayName, avatarEmoji, createdAt, lastActiveAt
///
/// /wellness_daily/{uid}/scores/{YYYY-MM-DD}
///   score, grade, totalPenalty, totalBonus, steps, date, updatedAt
///
/// /friend_requests/{reqId}
///   fromUid, toUid, fromDisplayName, fromAvatarEmoji, fromScore, fromGrade
///   status: 'pending' | 'accepted' | 'declined'
///   createdAt
///
/// /friendships/{uid_a}_{uid_b}   (UIDs sorted alphabetically)
///   users: [uid_a, uid_b], createdAt
/// ```
///
/// ## How data is shared fast between users
/// streamFriends() and streamRequests() use Firestore .snapshots() listeners
/// which propagate writes to all subscribed clients in ~100ms via Google's
/// global edge network.
///
/// ## How history is stored correctly
/// Each user's daily wellness score is stored as a separate document in a
/// subcollection: /wellness_daily/{uid}/scores/{YYYY-MM-DD}
/// This allows efficient range queries for charts/history while keeping each
/// day's data immutable once written.
///
/// ## Friend suggestions (friends of friends)
/// Computed client-side by fan-out query (read my friends' friend lists).
/// In production, offload this to a Cloud Function that pre-computes and
/// writes suggestions to /users/{uid}/suggestions/{suggestedUid}.
class FirebaseFriendsRepository extends FriendsRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  FirebaseFriendsRepository({
    required FirebaseFirestore db,
    required FirebaseAuth auth,
  })  : _db = db,
        _auth = auth;

  String get _myUid => _auth.currentUser!.uid;

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _compositeId(String a, String b) {
    final sorted = [a, b]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  // ── Real-time streams ─────────────────────────────────────────────────────

  @override
  Stream<List<Friend>> streamFriends() {
    return _db
        .collection('friendships')
        .where('users', arrayContains: _myUid)
        .snapshots()
        .asyncMap((snapshot) async {
      final friendUids = snapshot.docs
          .map((doc) => (doc['users'] as List<dynamic>)
              .cast<String>()
              .firstWhere((u) => u != _myUid))
          .toList();

      if (friendUids.isEmpty) return <Friend>[];

      final today = _today();
      final friends = await Future.wait(friendUids.map((uid) async {
        try {
          final profileFuture = _db.doc('users/$uid').get();
          final scoreFuture =
              _db.doc('wellness_daily/$uid/scores/$today').get();
          final results = await Future.wait([profileFuture, scoreFuture]);

          final profile = results[0];
          final score = results[1];
          if (!profile.exists) return null;

          final pd = profile.data()!;
          final sd = score.exists ? score.data()! : <String, dynamic>{};

          return Friend(
            id: uid,
            name: pd['displayName'] as String? ?? 'Unknown',
            avatarEmoji: pd['avatarEmoji'] as String? ?? '🙂',
            score: (sd['score'] as int?) ?? 0,
            grade: (sd['grade'] as String?) ?? 'F',
            isOnline: true,
          );
        } catch (_) {
          return null;
        }
      }));

      return friends.whereType<Friend>().toList()
        ..sort((a, b) => b.score.compareTo(a.score));
    });
  }

  @override
  Stream<List<FriendRequest>> streamRequests() {
    return _db
        .collection('friend_requests')
        .where('toUid', isEqualTo: _myUid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final d = doc.data();
              return FriendRequest(
                id: doc.id,
                name: d['fromDisplayName'] as String? ?? 'Unknown',
                avatarEmoji: d['fromAvatarEmoji'] as String? ?? '🙂',
                score: (d['fromScore'] as int?) ?? 0,
                grade: (d['fromGrade'] as String?) ?? 'F',
                mutualFriends: 0,
              );
            }).toList());
  }

  // ── One-shot reads (used as fallback) ─────────────────────────────────────

  @override
  Future<Either<Failure, List<Friend>>> getFriends() async {
    try {
      final friends = await streamFriends().first;
      return Right(friends);
    } catch (e) {
      return Left(ServerFailure('Failed to load friends: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FriendRequest>>> getPendingRequests() async {
    try {
      final requests = await streamRequests().first;
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure('Failed to load requests: $e'));
    }
  }

  // ── Friend-of-friend suggestions ──────────────────────────────────────────

  @override
  Future<Either<Failure, List<FriendSuggestion>>> getSuggestions() async {
    try {
      // Step 1: get my friends
      final mySnap = await _db
          .collection('friendships')
          .where('users', arrayContains: _myUid)
          .get();

      final myFriends = mySnap.docs
          .expand((d) => (d['users'] as List<dynamic>).cast<String>())
          .where((uid) => uid != _myUid)
          .toSet();

      if (myFriends.isEmpty) return const Right([]);

      // Step 2: for each friend, get their friends (fan-out)
      // Key: candidate UID  Value: list of mutual friend display names
      final Map<String, List<String>> mutualMap = {};

      await Future.wait(myFriends.map((friendUid) async {
        final theirSnap = await _db
            .collection('friendships')
            .where('users', arrayContains: friendUid)
            .get();

        // Get this friend's display name for the mutual-friend label
        final friendProfile = await _db.doc('users/$friendUid').get();
        final friendName =
            (friendProfile.data()?['displayName'] as String?) ?? 'Friend';

        for (final doc in theirSnap.docs) {
          final uids = (doc['users'] as List<dynamic>).cast<String>();
          for (final uid in uids) {
            if (uid != _myUid && !myFriends.contains(uid)) {
              mutualMap[uid] = [...(mutualMap[uid] ?? []), friendName];
            }
          }
        }
      }));

      if (mutualMap.isEmpty) return const Right([]);

      // Step 3: fetch profiles + today's score for each candidate
      final today = _today();
      final suggestions = await Future.wait(mutualMap.keys.map((uid) async {
        try {
          final profileFuture = _db.doc('users/$uid').get();
          final scoreFuture =
              _db.doc('wellness_daily/$uid/scores/$today').get();
          final results = await Future.wait([profileFuture, scoreFuture]);

          final profile = results[0];
          final score = results[1];
          if (!profile.exists) return null;

          final pd = profile.data()!;
          final sd = score.exists ? score.data()! : <String, dynamic>{};

          return FriendSuggestion(
            id: uid,
            name: pd['displayName'] as String? ?? 'Unknown',
            avatarEmoji: pd['avatarEmoji'] as String? ?? '🙂',
            score: (sd['score'] as int?) ?? 0,
            grade: (sd['grade'] as String?) ?? 'F',
            mutualFriendNames: mutualMap[uid]!,
          );
        } catch (_) {
          return null;
        }
      }));

      return Right(suggestions.whereType<FriendSuggestion>().toList()
        ..sort((a, b) => b.mutualCount.compareTo(a.mutualCount)));
    } catch (e) {
      return Left(ServerFailure('Failed to load suggestions: $e'));
    }
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> acceptRequest(String requestId) async {
    try {
      final doc = await _db.doc('friend_requests/$requestId').get();
      if (!doc.exists) return const Left(CacheFailure('Request not found'));

      final fromUid = doc.data()!['fromUid'] as String;
      final compositeId = _compositeId(_myUid, fromUid);

      final batch = _db.batch();
      batch.update(
          _db.doc('friend_requests/$requestId'), {'status': 'accepted'});
      batch.set(_db.doc('friendships/$compositeId'), {
        'users': [_myUid, fromUid],
        'createdAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to accept request: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> declineRequest(String requestId) async {
    try {
      await _db
          .doc('friend_requests/$requestId')
          .update({'status': 'declined'});
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to decline request: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> generateInviteText() async {
    try {
      final profileDoc = await _db.doc('users/$_myUid').get();
      final name =
          (profileDoc.data()?['displayName'] as String?) ?? 'a friend';
      final code =
          'DW${_myUid.substring(0, 6).toUpperCase()}${DateTime.now().millisecondsSinceEpoch % 1000}';

      // Store the invite code in Firestore so it can be redeemed
      await _db.collection('invite_codes').doc(code).set({
        'createdBy': _myUid,
        'createdAt': FieldValue.serverTimestamp(),
        'used': false,
      });

      final text = '🌟 $name invited you to Digital Wellness!\n\n'
          'Track your screen time, improve your habits, and compare scores.\n\n'
          'Invite code: $code\n'
          'https://digitalwellness.app/invite/$code';
      return Right(text);
    } catch (e) {
      // Fallback if Firebase call fails
      final code = 'DW${DateTime.now().millisecondsSinceEpoch % 100000}';
      return Right('🌟 Join me on Digital Wellness!\n\nInvite code: $code\n'
          'https://digitalwellness.app/invite/$code');
    }
  }

  // ── Send a friend request ─────────────────────────────────────────────────

  /// Creates a friend request document in Firestore.
  /// Called when a user taps "Add Friend" after receiving an invite link.
  Future<void> sendFriendRequest(String toUid) async {
    final profileDoc = await _db.doc('users/$_myUid').get();
    final today = _today();
    final scoreDoc = await _db.doc('wellness_daily/$_myUid/scores/$today').get();

    final pd = profileDoc.data() ?? {};
    final sd = scoreDoc.exists ? scoreDoc.data()! : <String, dynamic>{};

    await _db.collection('friend_requests').add({
      'fromUid': _myUid,
      'toUid': toUid,
      'fromDisplayName': pd['displayName'] ?? 'Unknown',
      'fromAvatarEmoji': pd['avatarEmoji'] ?? '🙂',
      'fromScore': (sd['score'] as int?) ?? 0,
      'fromGrade': (sd['grade'] as String?) ?? 'F',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
