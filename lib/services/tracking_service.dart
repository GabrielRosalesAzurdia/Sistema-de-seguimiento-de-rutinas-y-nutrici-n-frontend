import '../core/api_client.dart';

/// DRF serializa los `DecimalField` (peso inicial/final) como string
/// JSON ("100.0"), no como número — a diferencia de los campos que se
/// arman a mano con un dict plano (como exercise-progress), que sí
/// llegan como número. Se parsea de forma robusta para no asumir uno u
/// otro.
double _parseDecimal(dynamic value) =>
    value is num ? value.toDouble() : double.parse(value as String);

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

/// Detalle de un ejercicio dentro de una sesión del historial (pantalla
/// 'Historial'), tal como lo devuelve GET /api/tracking/me/workout-history/.
class WorkoutHistoryExerciseEntry {
  final int exerciseId;
  final String exerciseName;
  final double initialWeightLb;
  final double finalWeightLb;
  final int repsCompleted;

  WorkoutHistoryExerciseEntry({
    required this.exerciseId,
    required this.exerciseName,
    required this.initialWeightLb,
    required this.finalWeightLb,
    required this.repsCompleted,
  });

  factory WorkoutHistoryExerciseEntry.fromJson(Map<String, dynamic> json) =>
      WorkoutHistoryExerciseEntry(
        exerciseId: json['exercise'],
        exerciseName: json['exercise_name'],
        initialWeightLb: _parseDecimal(json['initial_weight_lb']),
        finalWeightLb: _parseDecimal(json['final_weight_lb']),
        repsCompleted: json['reps_completed'],
      );
}

/// Una sesión de rutina completada, tal como aparece en la pantalla
/// 'Historial' (lista y detalle).
class WorkoutHistorySession {
  final int id;
  final int routineId;
  final String routineCategoryDisplay;
  final int durationMinutes;
  final int? caloriesBurned;
  final DateTime completedAt;
  final List<WorkoutHistoryExerciseEntry> exerciseEntries;

  WorkoutHistorySession({
    required this.id,
    required this.routineId,
    required this.routineCategoryDisplay,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.completedAt,
    required this.exerciseEntries,
  });

  factory WorkoutHistorySession.fromJson(Map<String, dynamic> json) =>
      WorkoutHistorySession(
        id: json['id'],
        routineId: json['routine'],
        routineCategoryDisplay: json['routine_category_display'],
        durationMinutes: json['duration_minutes'],
        caloriesBurned: json['calories_burned'],
        completedAt: DateTime.parse(json['completed_at']),
        exerciseEntries: (json['exercise_entries'] as List)
            .map((e) => WorkoutHistoryExerciseEntry.fromJson(e))
            .toList(),
      );
}

/// Una página del historial (GET /api/tracking/me/workout-history/?page=N),
/// paginado por el backend con PageNumberPagination (20/página).
class WorkoutHistoryPage {
  final List<WorkoutHistorySession> results;
  final bool hasNext;

  WorkoutHistoryPage({required this.results, required this.hasNext});
}

/// Un punto de progreso de peso final para un ejercicio puntual (ver
/// GET /api/tracking/me/exercise-progress/<id>/).
class ExerciseProgressPoint {
  final DateTime date;
  final double finalWeightLb;

  ExerciseProgressPoint({required this.date, required this.finalWeightLb});

  factory ExerciseProgressPoint.fromJson(Map<String, dynamic> json) =>
      ExerciseProgressPoint(
        date: DateTime.parse(json['date']),
        finalWeightLb: _parseDecimal(json['final_weight_lb']),
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

  /// Pantalla 'Historial': lista paginada de sesiones del propio
  /// miembro, ordenadas por fecha descendente (ya viene así del
  /// backend). `page` empieza en 1, igual que PageNumberPagination.
  Future<WorkoutHistoryPage> getWorkoutHistory({int page = 1}) async {
    final response = await _client.dio.get(
      '/tracking/me/workout-history/',
      queryParameters: {'page': page},
    );
    final results = (response.data['results'] as List)
        .map((e) => WorkoutHistorySession.fromJson(e))
        .toList();
    return WorkoutHistoryPage(
      results: results,
      hasNext: response.data['next'] != null,
    );
  }

  /// Gráfica opcional de progreso de peso para un ejercicio puntual,
  /// a través de todas las sesiones históricas donde se registró.
  Future<List<ExerciseProgressPoint>> getExerciseProgress(
      int exerciseId) async {
    final response =
        await _client.dio.get('/tracking/me/exercise-progress/$exerciseId/');
    return (response.data as List)
        .map((e) => ExerciseProgressPoint.fromJson(e))
        .toList();
  }
}
