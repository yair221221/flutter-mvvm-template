import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';

enum UserSetupState { checking, needsOnboarding, ready, error }

class UserViewModel extends ChangeNotifier {
  final UserRepository _repository;

  UserSetupState _state = UserSetupState.checking;
  UserProfile? _currentUser;
  String? _errorMessage;

  UserViewModel({required UserRepository repository})
      : _repository = repository;

  UserSetupState get state => _state;
  UserProfile? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _state = UserSetupState.checking;
    notifyListeners();

    try {
      final user = await _repository.getCurrentUser();
      if (user == null) {
        _state = UserSetupState.needsOnboarding;
      } else {
        _currentUser = user;
        _state = UserSetupState.ready;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = UserSetupState.error;
    }
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String displayName,
    required String avatarEmoji,
  }) async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      final uid = FirebaseAuth.instance.currentUser!.uid;

      _currentUser = await _repository.saveProfile(
        uid: uid,
        displayName: displayName.trim(),
        avatarEmoji: avatarEmoji,
      );
      _state = UserSetupState.ready;
    } catch (e) {
      _errorMessage = e.toString();
      _state = UserSetupState.error;
    }
    notifyListeners();
  }
}
