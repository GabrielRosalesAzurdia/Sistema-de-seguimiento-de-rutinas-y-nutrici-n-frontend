class Exercise {
  final int id;
  final String name;
  final String? iconUrl;

  Exercise({required this.id, required this.name, this.iconUrl});

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'],
        name: json['name'],
        iconUrl: json['icon'],
      );
}

class RoutineExerciseItem {
  final int order;
  final Exercise exercise;

  RoutineExerciseItem({required this.order, required this.exercise});

  factory RoutineExerciseItem.fromJson(Map<String, dynamic> json) =>
      RoutineExerciseItem(
        order: json['order'],
        exercise: Exercise.fromJson(json['exercise']),
      );
}

/// Rutina semanal (una de las 7 categorías: Pierna-Cuádriceps, Pecho,
/// Brazos y Espalda, Cardio, ABS, Pierna-Glúteos, Hombro).
class Routine {
  final int id;
  final String category;
  final String categoryDisplay;
  final int durationLow;
  final int durationHigh;
  final int estimatedCalories;
  final List<RoutineExerciseItem> exercises;

  Routine({
    required this.id,
    required this.category,
    required this.categoryDisplay,
    required this.durationLow,
    required this.durationHigh,
    required this.estimatedCalories,
    required this.exercises,
  });

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
        id: json['id'],
        category: json['category'],
        categoryDisplay: json['category_display'] ?? json['category'],
        durationLow: json['estimated_duration_min_low'] ?? 60,
        durationHigh: json['estimated_duration_min_high'] ?? 90,
        estimatedCalories: json['estimated_calories'] ?? 0,
        exercises: (json['exercises'] as List? ?? [])
            .map((e) => RoutineExerciseItem.fromJson(e))
            .toList(),
      );
}
