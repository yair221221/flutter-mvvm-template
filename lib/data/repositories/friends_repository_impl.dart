import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friend_request.dart';
import '../../domain/entities/friend_suggestion.dart';
import '../../domain/repositories/friends_repository.dart';

class FriendsRepositoryImpl extends FriendsRepository {
  final SharedPreferences _prefs;

  static const _kFriendIds  = 'friends_friend_ids';
  static const _kDeclinedIds = 'friends_declined_ids';
  static const _kInitialized = 'friends_initialized';

  // ── Mock universe ────────────────────────────────────────────────────────────

  static const _initialFriendIds = [
    'f1','f2','f3','f4','f5','f6','f7','f8',
  ];

  static const _allFriends = <Friend>[
    Friend(id:'f1', name:'Alex Chen',     avatarEmoji:'🐱', score:84, grade:'B', isOnline:true),
    Friend(id:'f2', name:'Maya Patel',    avatarEmoji:'🦊', score:91, grade:'A', isOnline:false),
    Friend(id:'f3', name:'Sam Torres',    avatarEmoji:'🐸', score:67, grade:'C', isOnline:true),
    Friend(id:'f4', name:'Jordan Lee',    avatarEmoji:'🦁', score:72, grade:'B', isOnline:false),
    Friend(id:'f5', name:'Riley Kim',     avatarEmoji:'🐙', score:95, grade:'S', isOnline:true),
    Friend(id:'f6', name:'Casey Morgan',  avatarEmoji:'🦋', score:55, grade:'C', isOnline:false),
    Friend(id:'f7', name:'Quinn Reyes',   avatarEmoji:'🐻', score:79, grade:'B', isOnline:true),
    Friend(id:'f8', name:'Blake Nguyen',  avatarEmoji:'🦅', score:88, grade:'A', isOnline:false),
  ];

  static const _allRequesters = <FriendRequest>[
    FriendRequest(id:'r1', name:'Avery Walsh',   avatarEmoji:'🐝', score:74, grade:'B', mutualFriends:3),
    FriendRequest(id:'r2', name:'Sage Williams', avatarEmoji:'🦎', score:61, grade:'C', mutualFriends:2),
    FriendRequest(id:'r3', name:'Drew Martinez', avatarEmoji:'🐬', score:82, grade:'A', mutualFriends:5),
  ];

  static const _allSuggestions = <FriendSuggestion>[
    FriendSuggestion(
      id:'s1', name:'Kai Johnson',  avatarEmoji:'🦚', score:78, grade:'B',
      mutualFriendNames:['Alex Chen', 'Maya Patel'],
    ),
    FriendSuggestion(
      id:'s2', name:'Morgan Brown', avatarEmoji:'🦩', score:69, grade:'C',
      mutualFriendNames:['Riley Kim', 'Blake Nguyen', 'Jordan Lee'],
    ),
    FriendSuggestion(
      id:'s3', name:'Ash Davis',    avatarEmoji:'🐠', score:93, grade:'S',
      mutualFriendNames:['Maya Patel'],
    ),
    FriendSuggestion(
      id:'s4', name:'Noel Garcia',  avatarEmoji:'🌵', score:57, grade:'C',
      mutualFriendNames:['Casey Morgan', 'Sam Torres'],
    ),
    FriendSuggestion(
      id:'s5', name:'Rowan Clark',  avatarEmoji:'🦜', score:86, grade:'A',
      mutualFriendNames:['Quinn Reyes', 'Alex Chen'],
    ),
    FriendSuggestion(
      id:'s6', name:'Sunny Miller', avatarEmoji:'🐧', score:71, grade:'B',
      mutualFriendNames:['Blake Nguyen', 'Riley Kim', 'Maya Patel', 'Jordan Lee'],
    ),
  ];

  FriendsRepositoryImpl({required SharedPreferences prefs}) : _prefs = prefs {
    _seedIfNeeded();
  }

  void _seedIfNeeded() {
    if (!(_prefs.getBool(_kInitialized) ?? false)) {
      _prefs.setStringList(_kFriendIds, List.from(_initialFriendIds));
      _prefs.setStringList(_kDeclinedIds, []);
      _prefs.setBool(_kInitialized, true);
    }
  }

  Set<String> get _friendIds =>
      Set.from(_prefs.getStringList(_kFriendIds) ?? _initialFriendIds);

  Set<String> get _declinedIds =>
      Set.from(_prefs.getStringList(_kDeclinedIds) ?? []);

  // ── FriendsRepository interface ──────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Friend>>> getFriends() async {
    try {
      final ids = _friendIds;
      final friends = _allFriends.where((f) => ids.contains(f.id)).toList()
        ..sort((a, b) => b.score.compareTo(a.score));

      // Also include any accepted requesters
      for (final r in _allRequesters) {
        if (ids.contains(r.id)) {
          friends.add(Friend(
            id: r.id, name: r.name, avatarEmoji: r.avatarEmoji,
            score: r.score, grade: r.grade, isOnline: false,
          ));
        }
      }
      return Right(friends);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<FriendRequest>>> getPendingRequests() async {
    try {
      final ids = _friendIds;
      final declined = _declinedIds;
      final requests = _allRequesters
          .where((r) => !ids.contains(r.id) && !declined.contains(r.id))
          .toList();
      return Right(requests);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<FriendSuggestion>>> getSuggestions() async {
    try {
      final ids = _friendIds;
      final declined = _declinedIds;
      final suggestions = _allSuggestions
          .where((s) => !ids.contains(s.id) && !declined.contains(s.id))
          .toList()
        ..sort((a, b) =>
            b.mutualFriendNames.length.compareTo(a.mutualFriendNames.length));
      return Right(suggestions);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> acceptRequest(String id) async {
    try {
      final ids = List<String>.from(_friendIds)..add(id);
      await _prefs.setStringList(_kFriendIds, ids);
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> declineRequest(String id) async {
    try {
      final declined = List<String>.from(_declinedIds)..add(id);
      await _prefs.setStringList(_kDeclinedIds, declined);
      return const Right(null);
    } catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, String>> generateInviteText() async {
    final code = 'DW${DateTime.now().millisecondsSinceEpoch % 100000}';
    final text = '🌟 Hey! I\'m using Digital Wellness to track my screen time '
        'and improve my habits.\n\nJoin me and compare scores! 🏆\n\n'
        'My invite code: $code\nhttps://digitalwellness.app/invite/$code';
    return Right(text);
  }
}
