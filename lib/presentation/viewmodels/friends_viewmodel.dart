import 'package:flutter/material.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friend_request.dart';
import '../../domain/entities/friend_suggestion.dart';
import '../../domain/repositories/friends_repository.dart';
import '../../domain/usecases/get_friends_usecase.dart';
import '../../domain/usecases/get_requests_usecase.dart';
import '../../domain/usecases/get_suggestions_usecase.dart';
import '../../domain/usecases/accept_request_usecase.dart';
import '../../domain/usecases/decline_request_usecase.dart';

enum FriendsLoadState { initial, loading, success, error }

class FriendsViewModel extends ChangeNotifier {
  final GetFriendsUseCase _getFriends;
  final GetRequestsUseCase _getRequests;
  final GetSuggestionsUseCase _getSuggestions;
  final AcceptRequestUseCase _acceptRequest;
  final DeclineRequestUseCase _declineRequest;
  final FriendsRepository _repository;

  FriendsViewModel({
    required GetFriendsUseCase getFriends,
    required GetRequestsUseCase getRequests,
    required GetSuggestionsUseCase getSuggestions,
    required AcceptRequestUseCase acceptRequest,
    required DeclineRequestUseCase declineRequest,
    required FriendsRepository repository,
  })  : _getFriends = getFriends,
        _getRequests = getRequests,
        _getSuggestions = getSuggestions,
        _acceptRequest = acceptRequest,
        _declineRequest = declineRequest,
        _repository = repository;

  FriendsLoadState _state = FriendsLoadState.initial;
  List<Friend> _friends = [];
  List<FriendRequest> _requests = [];
  List<FriendSuggestion> _suggestions = [];
  final Set<String> _invitedIds = {};
  String? _errorMessage;

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

    String? error;

    (await _getFriends()).fold(
      (f) => error = f.message,
      (data) => _friends = data,
    );

    if (error != null) {
      _state = FriendsLoadState.error;
      _errorMessage = error;
      notifyListeners();
      return;
    }

    (await _getRequests()).fold(
      (f) => error = f.message,
      (data) => _requests = data,
    );

    (await _getSuggestions()).fold(
      (f) => error = f.message,
      (data) => _suggestions = data,
    );

    if (error != null) {
      _state = FriendsLoadState.error;
      _errorMessage = error;
    } else {
      _state = FriendsLoadState.success;
    }
    notifyListeners();
  }

  Future<void> accept(String id) async {
    final req = _requests.firstWhere((r) => r.id == id,
        orElse: () => const FriendRequest(
            id: '', name: '', avatarEmoji: '', score: 0, grade: 'F', mutualFriends: 0));
    if (req.id.isEmpty) return;

    (await _acceptRequest(id)).fold(
      (failure) => null,
      (_) {
        _requests.removeWhere((r) => r.id == id);
        _friends.insert(0, Friend(
          id: req.id,
          name: req.name,
          avatarEmoji: req.avatarEmoji,
          score: req.score,
          grade: req.grade,
          isOnline: false,
        ));
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
    return result.fold((f) => 'Join me on Digital Wellness! 🌟', (text) => text);
  }
}
