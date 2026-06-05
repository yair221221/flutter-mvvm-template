import 'package:equatable/equatable.dart';

class FriendSuggestion extends Equatable {
  final String id;
  final String name;
  final String avatarEmoji;
  final int score;
  final String grade;
  final List<String> mutualFriendNames;

  const FriendSuggestion({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.score,
    required this.grade,
    required this.mutualFriendNames,
  });

  int get mutualCount => mutualFriendNames.length;

  @override
  List<Object?> get props => [id, name, score, mutualFriendNames];
}
