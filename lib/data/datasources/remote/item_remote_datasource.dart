import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import '../../models/item_model.dart';

abstract class ItemRemoteDataSource {
  Future<List<ItemModel>> getItems();
}

class ItemRemoteDataSourceImpl implements ItemRemoteDataSource {
  final Dio dio;

  ItemRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ItemModel>> getItems() async {
    try {
      final response = await dio.get('/posts');
      if (response.statusCode == 200) {
        final List data = response.data as List;
        return data.map((json) => ItemModel.fromJson(json)).toList();
      }
      throw const ServerException();
    } on DioException {
      throw const NetworkException();
    }
  }
}
