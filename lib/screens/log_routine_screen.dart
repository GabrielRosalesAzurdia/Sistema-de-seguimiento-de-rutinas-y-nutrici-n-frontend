import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/routine.dart';
import '../services/tracking_service.dart';

/// "Registra el peso que usaste en cada ejercicio y el tiempo que te
/// tomó completar la rutina" (mockup, página 6). Ajuste de reunión 2
/// (A5): se registra peso inicial Y final, más repeticiones hechas.
class LogRoutineScreen extends StatefulWidget {
  final Routine routine;
  const LogRoutineScreen({super.key, required this.routine});

  @override
  State<LogRoutineScreen> createState() => _LogRoutineScreenState();
}

class _ExerciseFormState {
  final initialWeight = TextEditingController();
  final finalWeight = TextEditingController();
  final reps = TextEditingController();
}

class _LogRoutineScreenState extends State<LogRoutineScreen> {
  final _durationController = TextEditingController();
  final _service = TrackingService();
  late final Map<int, _ExerciseFormState> _forms;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _forms = {
      for (final item in widget.routine.exercises) item.exercise.id: _ExerciseFormState(),
    };
  }

  bool _allFieldsFilled() {
    if (_durationController.text.trim().isEmpty ||
        int.tryParse(_durationController.text) == null) {
      return false;
    }
    for (final form in _forms.values) {
      if (form.initialWeight.text.trim().isEmpty ||
          double.tryParse(form.initialWeight.text) == null ||
          form.finalWeight.text.trim().isEmpty ||
          double.tryParse(form.finalWeight.text) == null ||
          form.reps.text.trim().isEmpty ||
          int.tryParse(form.reps.text) == null) {
        return false;
      }
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_allFieldsFilled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Completa todos los campos antes de registrar la rutina.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final entries = widget.routine.exercises.map((item) {
        final form = _forms[item.exercise.id]!;
        return ExerciseLogEntry(
          exerciseId: item.exercise.id,
          initialWeightLb: double.tryParse(form.initialWeight.text) ?? 0,
          finalWeightLb: double.tryParse(form.finalWeight.text) ?? 0,
          repsCompleted: int.tryParse(form.reps.text) ?? 0,
        );
      }).toList();

      await _service.logWorkoutSession(
        routineId: widget.routine.id,
        durationMinutes: int.tryParse(_durationController.text) ?? 0,
        entries: entries,
      );

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Rutina registrada!')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.routine.categoryDisplay)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registra el peso que usaste en cada ejercicio y el '
                'tiempo que te tomó completar la rutina',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: widget.routine.exercises.map((item) {
                  final form = _forms[item.exercise.id]!;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.exercise.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _numberField(form.initialWeight, 'Peso inicial (lb)')),
                              const SizedBox(width: 8),
                              Expanded(child: _numberField(form.finalWeight, 'Peso final (lb)')),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _numberField(form.reps, 'Repeticiones hechas'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            _numberField(_durationController, 'Tiempo (minutos)'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Registrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(labelText: label),
    );
  }
}
