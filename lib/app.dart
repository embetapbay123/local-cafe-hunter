import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'cafes/repositories/local_cafe_repository.dart';
import 'cafes/viewmodels/cafe_viewmodel.dart';
import 'analytics/analytics_monitor_screen.dart';
import 'analytics/viewmodels/analytics_monitor_viewmodel.dart';
import 'notifications/notification_center_screen.dart';
import 'notifications/viewmodels/notification_center_viewmodel.dart';
import 'onboarding/onboarding_screen.dart';
import 'settings/settings_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/onboarding_service.dart';
import 'shared/app_routes.dart';
import 'theme/cafe_theme.dart';
import 'viewmodels/auth_viewmodel.dart';

class LocalCafeHunterApp extends StatelessWidget {
  const LocalCafeHunterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(
          create: (_) => CafeViewModel(LocalCafeRepository())..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationCenterViewModel()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => AnalyticsMonitorViewModel()..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Local Cafe Hunter',
        debugShowCheckedModeBanner: false,
        theme: buildCafeTheme(),
        home: const _AuthGate(),
        routes: {
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.onboarding: (context) => const OnboardingScreen(),
          AppRoutes.analytics: (context) => const AnalyticsMonitorScreen(),
          AppRoutes.notifications: (context) => const NotificationCenterScreen(),
          AppRoutes.settings: (context) => const SettingsScreen(),
          AppRoutes.home: (context) => const _AuthGate(),
        },
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final Future<bool> _onboardingCompleteFuture;

  @override
  void initState() {
    super.initState();
    _onboardingCompleteFuture = OnboardingService().isCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: CafeColors.dark),
            ),
          );
        }

        if (snapshot.data != null) {
          return FutureBuilder<bool>(
            future: _onboardingCompleteFuture,
            builder: (context, onboardingSnapshot) {
              if (onboardingSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: CafeColors.dark),
                  ),
                );
              }

              if (onboardingSnapshot.data == false) {
                return const OnboardingScreen();
              }

              return const HomeScreen();
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
