import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flutter_mvvm_template/core/usecases/usecase.dart';
import 'package:flutter_mvvm_template/domain/entities/item.dart';
import 'package:flutter_mvvm_template/domain/usecases/get_items_usecase.dart';
import 'package:flutter_mvvm_template/presentation/viewmodels/home_viewmodel.dart';

import 'home_viewmodel_test.mocks.dart';

@GenerateMocks([GetItemsUseCase])
void main() {
  late HomeViewModel viewModel;
  late MockGetItemsUseCase mockGetItems;

  setUp(() {
    mockGetItems = MockGetItemsUseCase();
    viewModel = HomeViewModel(getItems: mockGetItems);
  });

  const tItems = [
    Item(id: 1, title: 'Test Item', description: 'Test Desc'),
  ];

  test('initial state should be ViewState.initial', () {
    expect(viewModel.state, ViewState.initial);
  });

  test('fetchItems emits loading then success on success', () async {
    when(mockGetItems(any)).thenAnswer((_) async => const Right(tItems));

    final states = <ViewState>[];
    viewModel.addListener(() => states.add(viewModel.state));

    await viewModel.fetchItems();

    expect(states, [ViewState.loading, ViewState.success]);
    expect(viewModel.items, tItems);
  });
}
