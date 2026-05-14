import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'shared/app_routes.dart';
import 'viewmodels/auth_viewmodel.dart';

class LocalCafeHunterApp extends StatelessWidget {
  const LocalCafeHunterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: MaterialApp(
        title: 'Local Cafe Hunter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6F4E37),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const _AuthGate(),
        routes: {
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.home: (context) => const HomeScreen(),
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
              child: CircularProgressIndicator(),
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
