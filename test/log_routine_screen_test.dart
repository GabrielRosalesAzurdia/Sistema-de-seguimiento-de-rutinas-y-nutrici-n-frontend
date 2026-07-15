import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:club_fitness_app/models/routine.dart';
import 'package:club_fitness_app/screens/log_routine_screen.dart';

Routine _fakeRoutine() {
  return Routine(
    id: 1,
    category: 'PECHO',
    categoryDisplay: 'Pecho',
    durationLow: 60,
    durationHigh: 90,
    estimatedCalories: 400,
    exercises: [
      RoutineExerciseItem(order: 1, exercise: Exercise(id: 10, name: 'Press de banca')),
      RoutineExerciseItem(order: 2, exercise: Exercise(id: 11, name: 'Aperturas')),
    ],
  );
}

void main() {
  testWidgets('renders one form per exercise plus duration and submit button', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LogRoutineScreen(routine: _fakeRoutine())));

    expect(find.text('Press de banca'), findsOneWidget);
    expect(find.text('Aperturas'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Peso inicial (lb)'), findsNWidgets(2));
    expect(find.widgetWithText(TextField, 'Peso final (lb)'), findsNWidgets(2));
    expect(find.widgetWithText(TextField, 'Repeticiones hechas'), findsNWidgets(2));
    expect(find.widgetWithText(TextField, 'Tiempo (minutos)'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Registrar'), findsOneWidget);
  });

  testWidgets('accepts numeric input in weight fields', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LogRoutineScreen(routine: _fakeRoutine())));

    await tester.enterText(find.widgetWithText(TextField, 'Peso inicial (lb)').first, '135');
    await tester.pump();

    expect(find.text('135'), findsOneWidget);
  });

  testWidgets('blocks submit and shows an error when fields are left empty', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LogRoutineScreen(routine: _fakeRoutine())));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Registrar'));
    await tester.pump();

    expect(
      find.text('Completa todos los campos antes de registrar la rutina.'),
      findsOneWidget,
    );
  });
}
