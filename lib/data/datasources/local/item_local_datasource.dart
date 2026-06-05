import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/exceptions.dart';
import '../../models/item_model.dart';

abstract class ItemLocalDataSource {
  Future<List<ItemModel>> getCachedItems();
  Future<void> cacheItems(List<ItemModel> items);
}

const _cachedItemsKey = 'CACHED_ITEMS';

class ItemLocalDataSourceImpl implements ItemLocalDataSource {
  final SharedPreferences prefs;

  ItemLocalDataSourceImpl({required this.prefs});

  @override
  Future<List<ItemModel>> getCachedItems() async {
    final jsonString = prefs.getString(_cachedItemsKey);
    if (jsonString == null) throw const CacheException();
    final List decoded = json.decode(jsonString) as List;
    return decoded.map((e) => ItemModel.fromJson(e)).toList();
  }

  @override
  Future<void> cacheItems(List<ItemModel> items) async {
    await prefs.setString(
      _cachedItemsKey,
      json.encode(items.map((e) => e.toJson()).toList()),
    );
  }
}
