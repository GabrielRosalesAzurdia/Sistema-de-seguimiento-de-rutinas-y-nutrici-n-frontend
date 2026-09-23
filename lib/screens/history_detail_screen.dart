import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/routine.dart';
import '../services/tracking_service.dart';
import 'exercise_progress_screen.dart';

/// Detalle de una sesión del historial: peso inicial/final y
/// repeticiones por ejercicio (solo lectura, con los datos que ya
/// captura LogRoutineScreen al registrar). Recibe la sesión ya
/// cargada desde HistoryScreen — no hace una llamada nueva al backend.
class HistoryDetailScreen extends StatelessWidget {
  final WorkoutHistorySession session;

  const HistoryDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final date = session.completedAt;
    return Scaffold(
      appBar: AppBar(title: Text(session.routineCategoryDisplay)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              '${session.durationMinutes} min'
              '${session.caloriesBurned != null ? ' · ${session.caloriesBurned} kcal' : ''}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: session.exerciseEntries.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: AppColors.surface),
                itemBuilder: (context, index) {
                  final entry = session.exerciseEntries[index];
                  return ListTile(
                    title: Text(
                      stripExerciseNameSuffix(entry.exerciseName),
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      '${entry.initialWeightLb} lb → ${entry.finalWeightLb} lb · '
                      '${entry.repsCompleted} reps',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.show_chart, color: AppColors.yellow),
                      tooltip: 'Ver progreso',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ExerciseProgressScreen(
                            exerciseId: entry.exerciseId,
                            exerciseName: stripExerciseNameSuffix(entry.exerciseName),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
