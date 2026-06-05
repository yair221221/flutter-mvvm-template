import 'package:equatable/equatable.dart';

class Friend extends Equatable {
  final String id;
  final String name;
  final String avatarEmoji;
  final int score;
  final String grade;
  final bool isOnline;

  const Friend({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.score,
    required this.grade,
    required this.isOnline,
  });

  @override
  List<Object?> get props => [id, name, avatarEmoji, score, grade, isOnline];
}
