import '../core/api_client.dart';

class ExerciseLogEntry {
  final int exerciseId;
  final double initialWeightLb;
  final double finalWeightLb;
  final int repsCompleted;

  ExerciseLogEntry({
    required this.exerciseId,
    required this.initialWeightLb,
    required this.finalWeightLb,
    required this.repsCompleted,
  });

  Map<String, dynamic> toJson() => {
        'exercise': exerciseId,
        'initial_weight_lb': initialWeightLb,
        'final_weight_lb': finalWeightLb,
        'reps_completed': repsCompleted,
      };
}

class TrackingService {
  final _client = ApiClient.instance;

  /// Registra una rutina como completada (pantalla 'Registrar'): peso
  /// inicial/final y repeticiones por ejercicio + tiempo total.
  Future<void> logWorkoutSession({
    required int routineId,
    required int durationMinutes,
    required List<ExerciseLogEntry> entries,
  }) async {
    await _client.dio.post('/tracking/workout-logs/', data: {
      'routine': routineId,
      'duration_minutes': durationMinutes,
      'exercise_entries': entries.map((e) => e.toJson()).toList(),
    });
  }

  /// 'DIAS PARA META' del dashboard: predicción generada por el modelo
  /// scikit-learn (o heurística placeholder) en el backend.
  Future<int?> getDaysToGoal() async {
    final response = await _client.dio.get('/ml/me/progress/');
    return response.data['predicted_days_to_goal'];
  }
}
