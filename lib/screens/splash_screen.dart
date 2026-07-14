import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'main_nav_screen.dart';

/// Pantalla de splash inicial (mockup 01): logo del gimnasio sobre
/// fondo amarillo. Mientras se muestra, resuelve si hay sesión activa
/// y navega a Login o al flujo principal (reemplaza a `_RootDecider`).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideNext();
  }

  Future<void> _decideNext() async {
    final results = await Future.wait([
      AuthService().isLoggedIn(),
      Future.delayed(const Duration(milliseconds: 1200)),
    ]);
    final isLoggedIn = results[0] as bool;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? const MainNavScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.yellow,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/fitness club logo negro sin fondo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            const Text(
              'FITNESS CLUB',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
