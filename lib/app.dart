import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'cafes/repositories/local_cafe_repository.dart';
import 'cafes/viewmodels/cafe_viewmodel.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
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
      ],
      child: MaterialApp(
        title: 'Local Cafe Hunter',
        debugShowCheckedModeBanner: false,
        theme: buildCafeTheme(),
        home: const _AuthGate(),
        routes: {
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.home: (context) => const _AuthGate(),
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

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
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
