import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/utils/env_config.dart';
import 'core/utils/injection_container.dart' as di;
import 'presentation/pages/dashboard/dashboard_page.dart';
import 'presentation/viewmodels/dashboard_viewmodel.dart';
import 'presentation/viewmodels/home_viewmodel.dart';

// Entry point — reads FLUTTER_APP_FLAVOR dart-define (defaults to development)
void main() {
  const flavor = String.fromEnvironment(
    'FLUTTER_APP_FLAVOR',
    defaultValue: 'development',
  );
  final env = switch (flavor) {
    'production' => EnvConfig.production,
    'staging' => EnvConfig.staging,
    _ => EnvConfig.development,
  };
  _run(env);
}

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
        ChangeNotifierProvider(create: (_) => di.sl<DashboardViewModel>()),
      ],
      child: MaterialApp(
        title: 'Digital Wellness',
        debugShowCheckedModeBanner: env.showDebugBanner,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        builder: env.enableLogging
            ? (context, child) => _DevBanner(env: env, child: child!)
            : null,
        home: const DashboardPage(),
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
