import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_nav_screen.dart';

void main() {
  runApp(const ClubFitnessApp());
}

class ClubFitnessApp extends StatelessWidget {
  const ClubFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club Fitness App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _RootDecider(),
    );
  }
}

/// Decide si mostrar Login o el flujo principal, según haya sesión activa.
class _RootDecider extends StatelessWidget {
  const _RootDecider();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return (snapshot.data ?? false) ? const MainNavScreen() : const LoginScreen();
      },
    );
  }
}
