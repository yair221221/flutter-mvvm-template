import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final int id;
  final String title;
  final String description;

  const Item({
    required this.id,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [id, title, description];
}
