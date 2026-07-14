import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'main_nav_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final success = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    setState(() => _loading = false);
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
      );
    } else {
      setState(() => _error = 'Usuario o contraseña incorrectos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Bienvenido',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text('Inicia sesión para acceder',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Nombre de usuario'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Log In'),
              ),
              const SizedBox(height: 16),
              TextButton(
                // No hay flujo de autoservicio (requeriría envío de correos
                // desde el backend, fuera de alcance v1) — el remedio real
                // hoy es que el coach restablezca la contraseña desde el
                // panel/admin. Se avisa esto en vez de dejar el botón sin
                // reacción visible.
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Contacta a tu coach para restablecer tu contraseña.'),
                    ),
                  );
                },
                child: const Text('Olvidé mi contraseña',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
