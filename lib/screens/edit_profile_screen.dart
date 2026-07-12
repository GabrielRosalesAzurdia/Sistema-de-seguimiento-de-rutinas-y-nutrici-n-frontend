import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/member.dart';
import '../services/member_service.dart';

/// El usuario edita nombre, edad, altura, meta fitness y nivel de
/// actividad. Peso y medidas corporales NO son editables aquí por
/// decisión de negocio (solo el coach los registra desde el panel
/// admin, para evitar datos erróneos).
class EditProfileScreen extends StatefulWidget {
  final Member member;
  const EditProfileScreen({super.key, required this.member});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _service = MemberService();
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late String _fitnessGoal;
  late String _activityLevel;
  bool _saving = false;

  static const _goals = {
    'MANTENER_PESO': 'MANTENER PESO',
    'GANAR_PESO': 'SUBIR PESO',
    'PERDER_PESO': 'BAJAR PESO',
    'TONIFICAR': 'TONIFICAR',
  };

  static const _activityLevels = {
    'SEDENTARIO': 'SEDENTARIO',
    'MODERADO': 'MODERADO',
    'ACTIVO': 'ACTIVO',
    'MUY_ACTIVO': 'MUY ACTIVO',
  };

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(text: widget.member.age.toString());
    _heightController = TextEditingController(text: widget.member.heightCm.toString());
    _fitnessGoal = widget.member.fitnessGoal;
    _activityLevel = widget.member.activityLevel;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _service.updateMyProfile({
        'age': int.tryParse(_ageController.text),
        'height_cm': double.tryParse(_heightController.text),
        'fitness_goal': _fitnessGoal,
        'activity_level': _activityLevel,
      });
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Actualiza tu información', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Edad'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Altura (centímetros)'),
            ),
            const SizedBox(height: 20),
            const Text('META FITNESS', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _goals.entries.map((entry) {
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: _fitnessGoal == entry.key,
                  onSelected: (_) => setState(() => _fitnessGoal = entry.key),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('NIVEL DE ACTIVIDAD FÍSICA', style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _activityLevels.entries.map((entry) {
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: _activityLevel == entry.key,
                  onSelected: (_) => setState(() => _activityLevel = entry.key),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
