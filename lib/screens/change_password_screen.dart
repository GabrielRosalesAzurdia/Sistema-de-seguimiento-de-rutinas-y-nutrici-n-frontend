import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'main_nav_screen.dart';

/// Pantalla "Crear tu contraseña" — obligatoria tras el primer login
/// con la contraseña temporal generada por el panel (feedback de la
/// prueba E2E: la contraseña temporal es difícil de recordar). También
/// se usa, no obligatoria, desde Perfil para cambiar la contraseña en
/// cualquier momento.
class ChangePasswordScreen extends StatefulWidget {
  final bool isMandatory;

  const ChangePasswordScreen({required this.isMandatory, super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_newController.text != _confirmController.text) {
      setState(() => _error = 'Las contraseñas nuevas no coinciden.');
      return;
    }
    if (_newController.text.length < 8) {
      setState(() => _error = 'La nueva contraseña debe tener al menos 8 caracteres.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await _authService.changePassword(
      _currentController.text,
      _newController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error == null) {
      if (widget.isMandatory) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña actualizada.')),
        );
        Navigator.of(context).pop();
      }
    } else {
      setState(() => _error = error);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isMandatory,
      child: Scaffold(
        appBar: widget.isMandatory
            ? null
            : AppBar(title: const Text('Cambiar contraseña')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Crea tu contraseña',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                if (widget.isMandatory)
                  const Text(
                    'Por seguridad, cambia la contraseña temporal que te '
                    'compartió tu coach por una que puedas recordar.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                const SizedBox(height: 32),
                TextField(
                  controller: _currentController,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: widget.isMandatory ? 'Contraseña temporal' : 'Contraseña actual',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newController,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Nueva contraseña'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmController,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(labelText: 'Confirmar nueva contraseña'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.danger)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Guardar contraseña'),
                ),
                if (widget.isMandatory) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loading ? null : _logout,
                    child: const Text('Cerrar sesión', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
