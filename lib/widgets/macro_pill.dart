import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Par label/valor de un macro (proteína/carbohidratos/grasas), usado
/// en el Dashboard y en la pantalla de Nutrición (antes duplicado como
/// `_MacroPill` y `_MacroChip` respectivamente).
class MacroPill extends StatelessWidget {
  final String label;
  final int? grams;
  final Color color;

  const MacroPill(this.label, this.grams, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(grams != null ? '${grams}g' : '-',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}
