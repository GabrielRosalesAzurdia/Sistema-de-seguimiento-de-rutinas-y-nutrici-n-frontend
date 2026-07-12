import 'package:flutter/material.dart';

/// Paleta de marca confirmada con el gimnasio (Acta 1, 27/mar/2026 y
/// Cuestionario 2, A1): fondo negro con acentos amarillo, verde y
/// naranja "chinton". Todo el estilo visual fue aprobado sin cambios
/// ("Todo está bien").
class AppColors {
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const yellow = Color(0xFFFFD600);
  static const green = Color(0xFF00E676);
  static const orange = Color(0xFFFF6D00);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0B0);
  static const danger = Color(0xFFFF5252);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.yellow,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.yellow,
        secondary: AppColors.green,
        tertiary: AppColors.orange,
        surface: AppColors.surface,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.yellow,
        unselectedItemColor: AppColors.textSecondary,
      ),
    );
  }
}
