import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:club_fitness_app/screens/history_detail_screen.dart';
import 'package:club_fitness_app/services/tracking_service.dart';

WorkoutHistorySession _fakeSession() {
  return WorkoutHistorySession(
    id: 1,
    routineId: 2,
    routineCategoryDisplay: 'Pecho',
    durationMinutes: 45,
    caloriesBurned: 400,
    completedAt: DateTime(2026, 9, 20, 18, 30),
    exerciseEntries: [
      WorkoutHistoryExerciseEntry(
        exerciseId: 10,
        exerciseName: 'Prensa (Circuito)',
        initialWeightLb: 100,
        finalWeightLb: 120,
        repsCompleted: 10,
      ),
    ],
  );
}

void main() {
  testWidgets('renders session summary and exercise entries without the (Circuito) suffix',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: HistoryDetailScreen(session: _fakeSession())));

    expect(find.text('Pecho'), findsOneWidget);
    expect(find.text('20/9/2026'), findsOneWidget);
    expect(find.text('45 min · 400 kcal'), findsOneWidget);
    expect(find.text('Prensa'), findsOneWidget);
    expect(find.text('100.0 lb → 120.0 lb · 10 reps'), findsOneWidget);
  });
}
