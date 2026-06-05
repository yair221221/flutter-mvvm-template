import 'package:dartz/dartz.dart';
import '../entities/friend_suggestion.dart';
import '../repositories/friends_repository.dart';
import '../../core/error/failures.dart';

class GetSuggestionsUseCase {
  final FriendsRepository repository;
  const GetSuggestionsUseCase(this.repository);

  Future<Either<Failure, List<FriendSuggestion>>> call() =>
      repository.getSuggestions();
}
