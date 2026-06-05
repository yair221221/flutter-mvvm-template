import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/local/item_local_datasource.dart';
import '../datasources/remote/item_remote_datasource.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDataSource remote;
  final ItemLocalDataSource local;

  ItemRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, List<Item>>> getItems() async {
    try {
      final items = await remote.getItems();
      await local.cacheItems(items);
      return Right(items);
    } on NetworkException {
      try {
        final cached = await local.getCachedItems();
        return Right(cached);
      } on CacheException {
        return const Left(CacheFailure());
      }
    } on ServerException {
      return const Left(ServerFailure());
    }
  }
}
