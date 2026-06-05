import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friend_request.dart';
import '../../domain/entities/friend_suggestion.dart';
import '../../domain/repositories/friends_repository.dart';
import '../../domain/usecases/get_suggestions_usecase.dart';
import '../../domain/usecases/accept_request_usecase.dart';
import '../../domain/usecases/decline_request_usecase.dart';

enum FriendsLoadState { initial, loading, success, error }

class FriendsViewModel extends ChangeNotifier {
  final FriendsRepository _repository;
  final GetSuggestionsUseCase _getSuggestions;
  final AcceptRequestUseCase _acceptRequest;
  final DeclineRequestUseCase _declineRequest;

  FriendsViewModel({
    required FriendsRepository repository,
    required GetSuggestionsUseCase getSuggestions,
    required AcceptRequestUseCase acceptRequest,
    required DeclineRequestUseCase declineRequest,
  })  : _repository = repository,
        _getSuggestions = getSuggestions,
        _acceptRequest = acceptRequest,
        _declineRequest = declineRequest;

  FriendsLoadState _state = FriendsLoadState.initial;
  List<Friend> _friends = [];
  List<FriendRequest> _requests = [];
  List<FriendSuggestion> _suggestions = [];
  final Set<String> _invitedIds = {};
  String? _errorMessage;

  StreamSubscription<List<Friend>>? _friendsSub;
  StreamSubscription<List<FriendRequest>>? _requestsSub;

  FriendsLoadState get state => _state;
  List<Friend> get friends => _friends;
  List<FriendRequest> get requests => _requests;
  List<FriendSuggestion> get suggestions => _suggestions;
  Set<String> get invitedIds => _invitedIds;
  String? get errorMessage => _errorMessage;
  int get requestCount => _requests.length;

  Future<void> load() async {
    _state = FriendsLoadState.loading;
    notifyListeners();

    // Cancel any previous subscriptions before re-subscribing
    await _friendsSub?.cancel();
    await _requestsSub?.cancel();

    // Subscribe to real-time friend stream (Firestore or mock-wrapped Future)
    _friendsSub = _repository.streamFriends().listen(
      (friends) {
        _friends = friends;
        if (_state == FriendsLoadState.loading) {
          _state = FriendsLoadState.success;
        }
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Failed to load friends';
        _state = FriendsLoadState.error;
        notifyListeners();
      },
    );

    // Subscribe to real-time requests stream
    _requestsSub = _repository.streamRequests().listen(
      (requests) {
        _requests = requests;
        notifyListeners();
      },
    );

    // Suggestions are a one-shot fan-out query (not streamed)
    (await _getSuggestions()).fold(
      (f) { _errorMessage = f.message; },
      (data) { _suggestions = data; },
    );

    if (_state == FriendsLoadState.loading) {
      _state = FriendsLoadState.success;
    }
    notifyListeners();
  }

  Future<void> accept(String id) async {
    final req = _requests.firstWhere(
      (r) => r.id == id,
      orElse: () => const FriendRequest(
          id: '', name: '', avatarEmoji: '', score: 0, grade: 'F', mutualFriends: 0),
    );
    if (req.id.isEmpty) return;

    (await _acceptRequest(id)).fold(
      (failure) => null,
      (_) {
        // For the mock path (no real-time stream), update the lists optimistically
        _requests.removeWhere((r) => r.id == id);
        if (!_friends.any((f) => f.id == id)) {
          _friends.insert(
            0,
            Friend(
              id: req.id,
              name: req.name,
              avatarEmoji: req.avatarEmoji,
              score: req.score,
              grade: req.grade,
              isOnline: false,
            ),
          );
        }
        notifyListeners();
      },
    );
  }

  Future<void> decline(String id) async {
    (await _declineRequest(id)).fold(
      (failure) => null,
      (_) {
        _requests.removeWhere((r) => r.id == id);
        notifyListeners();
      },
    );
  }

  void markInvited(String id) {
    _invitedIds.add(id);
    notifyListeners();
  }

  Future<String> generateInviteText() async {
    final result = await _repository.generateInviteText();
    return result.fold((f) => 'Join me on Digital Wellness! ??', (text) => text);
  }

  @override
  void dispose() {
    _friendsSub?.cancel();
    _requestsSub?.cancel();
    super.dispose();
  }
}
