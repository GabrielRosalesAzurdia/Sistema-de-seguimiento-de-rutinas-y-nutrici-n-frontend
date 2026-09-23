import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/tracking_service.dart';

/// Gráfica de línea del peso final registrado para un ejercicio, a
/// través de sus sesiones históricas (pantalla 'Historial' -> detalle
/// de sesión -> "Ver progreso"). Mismo enfoque de eje X que
/// WeightChartCard (días transcurridos desde el primer punto, no el
/// índice de la lista), adaptado a fechas de sesiones de entrenamiento
/// (más frecuentes que los pesajes mensuales del coach, así que el
/// eje X muestra día/mes en vez de solo el mes).
class ExerciseProgressChart extends StatelessWidget {
  final List<ExerciseProgressPoint> points;

  const ExerciseProgressChart({required this.points, super.key});

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Registrá este ejercicio en al menos 2 sesiones para ver tu progreso.',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final firstDate = points.first.date;
    final offsets = [
      for (final point in points)
        point.date.difference(firstDate).inDays.toDouble(),
    ];
    final dateByOffset = {
      for (var i = 0; i < points.length; i++) offsets[i]: points[i].date,
    };

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: offsets.last,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: Colors.white10, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()} lb',
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final date = dateByOffset[value.roundToDouble()];
                  if (date == null) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${date.day}/${date.month}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(offsets[i], points[i].finalWeightLb),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: AppColors.green,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}
