import 'package:flutter_test/flutter_test.dart';
import 'package:club_fitness_app/models/routine.dart';

void main() {
  group('Exercise.displayName', () {
    test('strips a trailing parenthetical suffix', () {
      final exercise = Exercise(id: 1, name: 'Prensa (Circuito)');
      expect(exercise.displayName, 'Prensa');
    });

    test('leaves a name without a suffix unchanged', () {
      final exercise = Exercise(id: 1, name: 'Bícep Curl');
      expect(exercise.displayName, 'Bícep Curl');
    });

    test('strips a multi-word parenthetical suffix', () {
      final exercise = Exercise(id: 1, name: 'Despechadas (P+H+T)');
      expect(exercise.displayName, 'Despechadas');
    });

    test('keeps parentheses that are not at the end of the name', () {
      final exercise =
          Exercise(id: 1, name: 'Sentadilla Búlgara (Cuádriceps) extra');
      expect(exercise.displayName, 'Sentadilla Búlgara (Cuádriceps) extra');
    });
  });
}
