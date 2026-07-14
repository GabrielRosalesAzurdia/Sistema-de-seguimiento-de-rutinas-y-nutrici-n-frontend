import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ClubFitnessApp());
}

class ClubFitnessApp extends StatelessWidget {
  const ClubFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club Fitness App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
