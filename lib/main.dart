import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/firebase_config.dart';
import 'core/navigation/shell_page.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/env_config.dart';
import 'core/utils/injection_container.dart' as di;
import 'presentation/pages/onboarding/onboarding_page.dart';
import 'presentation/viewmodels/dashboard_viewmodel.dart';
import 'presentation/viewmodels/friends_viewmodel.dart';
import 'presentation/viewmodels/home_viewmodel.dart';
import 'presentation/viewmodels/user_viewmodel.dart';

void main() {
  const flavor = String.fromEnvironment('FLUTTER_APP_FLAVOR', defaultValue: 'development');
  final env = switch (flavor) {
    'production' => EnvConfig.production,
    'staging'    => EnvConfig.staging,
    _            => EnvConfig.development,
  };
  _run(env);
}

void mainDev()     => _run(EnvConfig.development);
void mainStaging() => _run(EnvConfig.staging);

Future<void> _run(EnvConfig env) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kFirebaseEnabled) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('[Firebase] Init failed — running in offline mode: $e');
    }
  }

  await di.init(env: env);

  // Pre-initialize user state so the home screen knows immediately
  // whether to show onboarding or the main shell.
  if (kFirebaseEnabled) {
    await di.sl<UserViewModel>().initialize();
  }

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
        ChangeNotifierProvider(create: (_) => di.sl<FriendsViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<UserViewModel>()),
      ],
      child: MaterialApp(
        title: 'Digital Wellness',
        debugShowCheckedModeBanner: env.showDebugBanner,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        builder: env.enableLogging
            ? (context, child) => _DevBanner(env: env, child: child!)
            : null,
        home: kFirebaseEnabled ? const _FirebaseHome() : const ShellPage(),
      ),
    );
  }
}

/// Routes to OnboardingPage on first launch, ShellPage thereafter.
/// Only used when [kFirebaseEnabled] is true.
class _FirebaseHome extends StatelessWidget {
  const _FirebaseHome();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(builder: (_, vm, __) {
      return switch (vm.state) {
        UserSetupState.checking      => const _SplashScreen(),
        UserSetupState.needsOnboarding => const OnboardingPage(),
        UserSetupState.ready         => const ShellPage(),
        UserSetupState.error         => const ShellPage(), // fallback
      };
    });
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Color(0xFF0E0E10),
        body: Center(
          child: CircularProgressIndicator(
              color: Color(0xFF00F0FF), strokeWidth: 2),
        ),
      );
}

class _DevBanner extends StatelessWidget {
  final EnvConfig env;
  final Widget child;
  const _DevBanner({required this.env, required this.child});

  @override
  Widget build(BuildContext context) {
    return Banner(
      message: env.name.toUpperCase(),
      location: BannerLocation.topStart,
      color: env.name == 'staging' ? Colors.orange : const Color(0xFF00F0FF),
      child: child,
    );
  }
}
