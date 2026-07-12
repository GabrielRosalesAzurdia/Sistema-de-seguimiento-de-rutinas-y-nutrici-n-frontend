import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'routines_screen.dart';
import 'nutrition_screen.dart';
import 'profile_screen.dart';

/// Flujo de navegación confirmado con el gimnasio (A2, Cuestionario 2:
/// "Todo está bien"): Inicio → Rutinas → Nutrición → Perfil.
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    RoutinesScreen(),
    NutritionScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'INICIO'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined), label: 'RUTINAS'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_outlined), label: 'NUTRICIÓN'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'PERFIL'),
        ],
      ),
    );
  }
}
