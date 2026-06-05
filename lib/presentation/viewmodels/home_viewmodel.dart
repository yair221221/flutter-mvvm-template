import 'package:flutter/foundation.dart';

import '../../core/usecases/usecase.dart';
import '../../domain/entities/item.dart';
import '../../domain/usecases/get_items_usecase.dart';

enum ViewState { initial, loading, success, error }

class HomeViewModel extends ChangeNotifier {
  final GetItemsUseCase getItems;

  HomeViewModel({required this.getItems});

  ViewState _state = ViewState.initial;
  List<Item> _items = [];
  String _errorMessage = '';

  ViewState get state => _state;
  List<Item> get items => _items;
  String get errorMessage => _errorMessage;

  Future<void> fetchItems() async {
    _state = ViewState.loading;
    notifyListeners();

    final result = await getItems(NoParams());

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _state = ViewState.error;
      },
      (items) {
        _items = items;
        _state = ViewState.success;
      },
    );

    notifyListeners();
  }
}
