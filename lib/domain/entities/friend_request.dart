import 'package:equatable/equatable.dart';

class FriendRequest extends Equatable {
  final String id;
  final String name;
  final String avatarEmoji;
  final int score;
  final String grade;
  final int mutualFriends;

  const FriendRequest({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.score,
    required this.grade,
    required this.mutualFriends,
  });

  @override
  List<Object?> get props => [id, name, score, mutualFriends];
}
