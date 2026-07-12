class MealSuggestion {
  final String mealTime;
  final String mealTimeDisplay;
  final int carbsG;
  final int proteinG;
  final int fatsG;
  final int calories;
  final List<String> suggestions;

  MealSuggestion({
    required this.mealTime,
    required this.mealTimeDisplay,
    required this.carbsG,
    required this.proteinG,
    required this.fatsG,
    required this.calories,
    required this.suggestions,
  });

  factory MealSuggestion.fromJson(Map<String, dynamic> json) => MealSuggestion(
        mealTime: json['meal_time'],
        mealTimeDisplay: json['meal_time_display'] ?? json['meal_time'],
        carbsG: json['carbs_g'] ?? 0,
        proteinG: json['protein_g'] ?? 0,
        fatsG: json['fats_g'] ?? 0,
        calories: json['calories'] ?? 0,
        suggestions: [
          json['suggestion_1'],
          json['suggestion_2'],
          json['suggestion_3'],
        ].whereType<String>().where((s) => s.isNotEmpty).toList(),
      );
}

/// Plan nutricional vigente y APROBADO por el coach (solo macros,
/// 5 tiempos de comida: Desayuno, Refacción I, Almuerzo, Refacción II, Cena).
class NutritionPlan {
  final int id;
  final int totalCalories;
  final int proteinG;
  final int carbsG;
  final int fatsG;
  final List<MealSuggestion> meals;

  NutritionPlan({
    required this.id,
    required this.totalCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required this.meals,
  });

  factory NutritionPlan.fromJson(Map<String, dynamic> json) => NutritionPlan(
        id: json['id'],
        totalCalories: json['total_calories'] ?? 0,
        proteinG: json['protein_g'] ?? 0,
        carbsG: json['carbs_g'] ?? 0,
        fatsG: json['fats_g'] ?? 0,
        meals: (json['meals'] as List? ?? [])
            .map((m) => MealSuggestion.fromJson(m))
            .toList(),
      );
}

/// Estados del semáforo diario (dashboard: SEGUIMIENTO DE NUTRICIÓN DIARIO).
enum NutritionCheckStatus { hecho, parcialmente, seMeFue }

extension NutritionCheckStatusX on NutritionCheckStatus {
  String get apiValue {
    switch (this) {
      case NutritionCheckStatus.hecho:
        return 'HECHO';
      case NutritionCheckStatus.parcialmente:
        return 'PARCIALMENTE';
      case NutritionCheckStatus.seMeFue:
        return 'SE_ME_FUE';
    }
  }

  String get label {
    switch (this) {
      case NutritionCheckStatus.hecho:
        return 'HECHO';
      case NutritionCheckStatus.parcialmente:
        return 'PARCIALMENTE';
      case NutritionCheckStatus.seMeFue:
        return 'SE ME FUE';
    }
  }
}
