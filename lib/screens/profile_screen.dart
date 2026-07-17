import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/member.dart';
import '../services/auth_service.dart';
import '../services/member_service.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = MemberService();
  final _authService = AuthService();
  late Future<Member> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMyProfile();
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<Member>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final member = snapshot.data;
            if (member == null) {
              return const Center(child: Text('No se pudo cargar el perfil'));
            }
            return ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Perfil',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => EditProfileScreen(member: member)),
                            );
                            if (!mounted) return;
                            setState(() {
                              _future = _service.getMyProfile();
                            });
                          },
                          child: const Text('Editar', style: TextStyle(color: AppColors.yellow)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ChangePasswordScreen(isMandatory: false),
                              ),
                            );
                          },
                          child: const Text('Contraseña', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                        IconButton(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout, color: AppColors.danger),
                          tooltip: 'Cerrar sesión',
                        ),
                      ],
                    ),
                  ],
                ),
                const Text('Administra tu información', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                _Section('INFORMACIÓN BÁSICA', [
                  _InfoRow('Nombre', member.fullName),
                  _InfoRow('Edad', '${member.age} años'),
                  _InfoRow('Altura', '${member.heightCm} cm'),
                  _InfoRow('Peso', member.currentWeightKg != null ? '${member.currentWeightKg} kg' : '-'),
                ]),
                _Section('MEDIDAS CORPORALES', [
                  _InfoRow('Brazos', member.leftArmCm != null ? '${member.leftArmCm} cm' : '-'),
                  _InfoRow('Cintura', member.waistCm != null ? '${member.waistCm} cm' : '-'),
                ]),
                _Section('META FITNESS', [
                  _InfoRow('Meta', member.fitnessGoal.replaceAll('_', ' ')),
                ]),
                _Section('NIVEL DE ACTIVIDAD FÍSICA', [
                  _InfoRow('Nivel', member.activityLevel.replaceAll('_', ' ')),
                ]),
                const SizedBox(height: 8),
                const Text(
                  'El peso y las medidas corporales son registrados por tu '
                  'coach durante tu evaluación mensual.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.yellow, fontSize: 12)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
