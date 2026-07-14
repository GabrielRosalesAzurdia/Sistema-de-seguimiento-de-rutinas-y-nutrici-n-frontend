import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Tarjeta de una métrica (label + valor destacado), usada en el
/// grid 2x2 del Dashboard (peso/meta, % grasa, % agua, días para
/// meta, racha).
class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const MetricCard(
      {required this.label, required this.value, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
