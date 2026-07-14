import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:club_fitness_app/screens/login_screen.dart';

/// Nota: AuthService/ApiClient no tienen inyección de dependencias
/// (ver docs/frontend_arquitectura.md, sección 9) — no hay forma de
/// mockear la llamada de red sin tocar arquitectura. Estos tests solo
/// cubren la estructura de la UI y las interacciones que no dependen
/// de completar una request real.
void main() {
  testWidgets('renders email, password fields and login button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Nombre de usuario'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);
    expect(find.text('Olvidé mi contraseña'), findsOneWidget);
  });

  testWidgets('tapping "Olvidé mi contraseña" shows a message instead of doing nothing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Olvidé mi contraseña'));
    await tester.pump();

    expect(find.text('Contacta a tu coach para restablecer tu contraseña.'), findsOneWidget);
  });
}
