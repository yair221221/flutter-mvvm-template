import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/utils/injection_container.dart' as di;
import 'presentation/pages/home/home_page.dart';
import 'presentation/viewmodels/home_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<HomeViewModel>()),
      ],
      child: MaterialApp(
        title: 'Flutter MVVM Template',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
