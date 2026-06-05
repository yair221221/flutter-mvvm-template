import 'package:equatable/equatable.dart';

/// The current user's profile stored in Firestore at /users/{uid}.
class UserProfile extends Equatable {
  final String uid;
  final String displayName;
  final String avatarEmoji;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.avatarEmoji,
  });

  @override
  List<Object?> get props => [uid, displayName, avatarEmoji];
}
