import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/item_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<HomeViewModel>().fetchItems(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          switch (vm.state) {
            case ViewState.loading:
            case ViewState.initial:
              return const Center(child: CircularProgressIndicator());
            case ViewState.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(vm.errorMessage),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: vm.fetchItems,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            case ViewState.success:
              return ListView.builder(
                itemCount: vm.items.length,
                itemBuilder: (context, index) =>
                    ItemCard(item: vm.items[index]),
              );
          }
        },
      ),
    );
  }
}
