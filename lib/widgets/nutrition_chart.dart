import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/nutrition_plan.dart';

/// Dona de macros + leyenda (docs/mockups: "nutricion chart mockup.png"
/// — no se exportó del mockup original de Figma por un error, feedback
/// de la prueba E2E). Calorías totales al centro; el tamaño de cada
/// gajo es proporcional a su aporte calórico real (carbos/proteína =
/// 4 kcal/g, grasas = 9 kcal/g), no a los gramos crudos.
class NutritionDonutChart extends StatelessWidget {
  final NutritionPlan plan;

  const NutritionDonutChart({required this.plan, super.key});

  @override
  Widget build(BuildContext context) {
    final carbsCal = plan.carbsG * 4;
    final proteinCal = plan.proteinG * 4;
    final fatsCal = plan.fatsG * 9;
    final total = carbsCal + proteinCal + fatsCal;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 34,
                      sections: [
                        _section(carbsCal, total, AppColors.yellow),
                        _section(proteinCal, total, AppColors.orange),
                        _section(fatsCal, total, AppColors.green),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${plan.totalCalories}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const Text('CAL', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendItem('CARBOHIDRATOS', plan.carbsG, AppColors.yellow),
                  const SizedBox(height: 10),
                  _LegendItem('PROTEÍNAS', plan.proteinG, AppColors.orange),
                  const SizedBox(height: 10),
                  _LegendItem('GRASAS', plan.fatsG, AppColors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _section(int calories, int total, Color color) {
    return PieChartSectionData(
      value: total > 0 ? calories.toDouble() : 1,
      color: color,
      radius: 18,
      showTitle: false,
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final int grams;
  final Color color;

  const _LegendItem(this.label, this.grams, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ),
        Text('${grams}g',
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
