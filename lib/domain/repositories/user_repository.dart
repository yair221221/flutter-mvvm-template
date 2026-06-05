import '../entities/user_profile.dart';

/// Manages the current user's identity and Firestore profile.
abstract class UserRepository {
  /// Returns the current user's profile, or null if not yet set up.
  /// Creates an anonymous Firebase Auth user on first call.
  Future<UserProfile?> getCurrentUser();

  /// Creates or updates the profile document at /users/{uid}.
  Future<UserProfile> saveProfile({
    required String uid,
    required String displayName,
    required String avatarEmoji,
  });

  /// True when the user has never completed the onboarding flow.
  Future<bool> isFirstLaunch();
}
