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

/// Resumen para las cards "CALORÍAS QUEMADAS EN TOTAL" y "RACHA" del
/// dashboard (ver GET /api/tracking/me/summary/).
class TrackingSummary {
  final int totalCaloriesBurned;
  final int streakDays;

  TrackingSummary({required this.totalCaloriesBurned, required this.streakDays});

  factory TrackingSummary.fromJson(Map<String, dynamic> json) => TrackingSummary(
        totalCaloriesBurned: json['total_calories_burned'] ?? 0,
        streakDays: json['streak_days'] ?? 0,
      );
}

/// Un punto del historial de peso (ver GET /api/tracking/me/weight-history/).
class WeightPoint {
  final DateTime date;
  final double weightKg;

  WeightPoint({required this.date, required this.weightKg});

  factory WeightPoint.fromJson(Map<String, dynamic> json) => WeightPoint(
        date: DateTime.parse(json['date']),
        weightKg: (json['weight_kg'] as num).toDouble(),
      );
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

  /// 'CALORÍAS QUEMADAS EN TOTAL' y 'RACHA' del dashboard.
  Future<TrackingSummary> getSummary() async {
    final response = await _client.dio.get('/tracking/me/summary/');
    return TrackingSummary.fromJson(response.data);
  }

  /// Historial de peso (mediciones mensuales del coach) para la
  /// gráfica de la card 'PESO ACTUAL / META'.
  Future<List<WeightPoint>> getWeightHistory() async {
    final response = await _client.dio.get('/tracking/me/weight-history/');
    return (response.data as List)
        .map((e) => WeightPoint.fromJson(e))
        .toList();
  }
}
