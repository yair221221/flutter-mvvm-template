import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/utils/env_config.dart';
import 'core/utils/injection_container.dart' as di;
import 'presentation/pages/home/home_page.dart';
import 'presentation/viewmodels/home_viewmodel.dart';

// Entry points per environment
void main() => _run(EnvConfig.production);
void mainDev() => _run(EnvConfig.development);
void mainStaging() => _run(EnvConfig.staging);

Future<void> _run(EnvConfig env) async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(env: env);
  runApp(MyApp(env: env));
}

class MyApp extends StatelessWidget {
  final EnvConfig env;
  const MyApp({super.key, required this.env});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<HomeViewModel>()),
      ],
      child: MaterialApp(
        title: 'Flutter MVVM Template',
        debugShowCheckedModeBanner: env.showDebugBanner,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        builder: env.enableLogging
            ? (context, child) => _DevBanner(env: env, child: child!)
            : null,
        home: const HomePage(),
      ),
    );
  }
}

/// Thin banner shown only in non-production environments.
class _DevBanner extends StatelessWidget {
  final EnvConfig env;
  final Widget child;
  const _DevBanner({required this.env, required this.child});

  @override
  Widget build(BuildContext context) {
    return Banner(
      message: env.name.toUpperCase(),
      location: BannerLocation.topStart,
      color: env.name == 'staging' ? Colors.orange : Colors.green,
      child: child,
    );
  }
}
