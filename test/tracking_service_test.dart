import 'package:flutter_test/flutter_test.dart';
import 'package:club_fitness_app/services/tracking_service.dart';

void main() {
  group('WorkoutHistoryExerciseEntry.fromJson', () {
    test('parses weight fields when the backend sends them as strings', () {
      // DRF serializa DecimalField como string JSON ("100.0") por
      // default (COERCE_DECIMAL_TO_STRING) — comportamiento real
      // confirmado contra el backend local, no solo supuesto.
      final entry = WorkoutHistoryExerciseEntry.fromJson({
        'exercise': 84,
        'exercise_name': 'Prensa (Circuito)',
        'initial_weight_lb': '100.0',
        'final_weight_lb': '120.0',
        'reps_completed': 10,
      });
      expect(entry.initialWeightLb, 100.0);
      expect(entry.finalWeightLb, 120.0);
    });

    test('also parses weight fields when sent as numbers', () {
      final entry = WorkoutHistoryExerciseEntry.fromJson({
        'exercise': 84,
        'exercise_name': 'Prensa',
        'initial_weight_lb': 100.0,
        'final_weight_lb': 120.0,
        'reps_completed': 10,
      });
      expect(entry.initialWeightLb, 100.0);
      expect(entry.finalWeightLb, 120.0);
    });
  });

  group('ExerciseProgressPoint.fromJson', () {
    test('parses a numeric final_weight_lb', () {
      final point = ExerciseProgressPoint.fromJson({
        'date': '2026-09-23',
        'final_weight_lb': 120.0,
      });
      expect(point.finalWeightLb, 120.0);
      expect(point.date, DateTime(2026, 9, 23));
    });

    test('also parses a string final_weight_lb', () {
      final point = ExerciseProgressPoint.fromJson({
        'date': '2026-09-23',
        'final_weight_lb': '120.0',
      });
      expect(point.finalWeightLb, 120.0);
    });
  });
}
