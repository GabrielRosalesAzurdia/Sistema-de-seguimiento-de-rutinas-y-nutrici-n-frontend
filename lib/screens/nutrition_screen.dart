import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/nutrition_plan.dart';
import '../services/nutrition_service.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _service = NutritionService();
  late Future<NutritionPlan?> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMyCurrentPlan();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nutrición',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const Text('Este es tu plan de nutrición diario basado en tus objetivos y tu persona',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<NutritionPlan?>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final plan = snapshot.data;
                  if (plan == null) {
                    return const Center(
                      child: Text(
                        'Tu plan nutricional está pendiente de aprobación por '
                        'el coach. Vuelve pronto.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MacroChip('CARBOHIDRATOS', plan.carbsG, AppColors.yellow),
                          _MacroChip('PROTEÍNAS', plan.proteinG, AppColors.green),
                          _MacroChip('GRASAS', plan.fatsG, AppColors.orange),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...plan.meals.map((meal) => _MealCard(meal: meal)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final int grams;
  final Color color;
  const _MacroChip(this.label, this.grams, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${grams}g', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealSuggestion meal;
  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(meal.mealTimeDisplay,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text('${meal.calories} CAL', style: const TextStyle(color: AppColors.yellow)),
              ],
            ),
            Text('C: ${meal.carbsG}g  P: ${meal.proteinG}g  G: ${meal.fatsG}g',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            ...meal.suggestions.map((s) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text('• $s', style: const TextStyle(color: AppColors.textSecondary)),
                )),
          ],
        ),
      ),
    );
  }
}
