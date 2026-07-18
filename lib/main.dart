import 'package:flutter/material.dart';
import 'core/api_client.dart';
import 'core/navigation.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.clearStaleTokensOnFirstLaunch();
  runApp(const ClubFitnessApp());
}

class ClubFitnessApp extends StatelessWidget {
  const ClubFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club Fitness App',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
