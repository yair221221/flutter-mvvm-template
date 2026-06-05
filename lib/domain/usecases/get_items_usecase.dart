import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/item.dart';
import '../repositories/item_repository.dart';

class GetItemsUseCase implements UseCase<List<Item>, NoParams> {
  final ItemRepository repository;

  GetItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Item>>> call(NoParams params) {
    return repository.getItems();
  }
}
