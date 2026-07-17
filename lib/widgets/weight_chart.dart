import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/member.dart';
import '../services/tracking_service.dart';

const _monthAbbr = [
  '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
  'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
];

/// Card "PESO ACTUAL / META" con la gráfica de línea del historial de
/// peso (docs/mockups/app/03_dashboard.jpeg). Sin historial todavía
/// (miembro nuevo, coach no ha registrado medidas), se muestra solo
/// el valor actual/meta sin gráfica.
class WeightChartCard extends StatelessWidget {
  final Member? member;
  final List<WeightPoint> history;

  const WeightChartCard({required this.member, required this.history, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PESO ACTUAL',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    Text(
                      member?.currentWeightKg != null
                          ? '${member!.currentWeightKg} kg'
                          : '-',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('META', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    Text(
                      member?.goalWeightKg != null ? '${member!.goalWeightKg} kg' : '-',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.green),
                    ),
                  ],
                ),
              ],
            ),
            if (history.length >= 2) ...[
              const SizedBox(height: 16),
              _buildChart(),
            ],
          ],
        ),
      ),
    );
  }

  // El eje X usa días transcurridos desde el primer registro (no el
  // índice de la lista) para que la posición de cada punto refleje su
  // fecha real — si hay 2 pesajes en el mismo mes, quedan visualmente
  // juntos en vez de equiespaciados como si fueran meses distintos
  // (feedback de la prueba E2E).
  Widget _buildChart() {
    final firstDate = history.first.date;
    final offsets = [
      for (final point in history)
        point.date.difference(firstDate).inDays.toDouble(),
    ];
    final monthByOffset = {
      for (var i = 0; i < history.length; i++) offsets[i]: history[i].date.month,
    };
    return SizedBox(
      height: 130,
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
                reservedSize: 34,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()} kg',
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final month = monthByOffset[value.roundToDouble()];
                  if (month == null) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _monthAbbr[month],
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
                for (var i = 0; i < history.length; i++) FlSpot(offsets[i], history[i].weightKg),
              ],
              isCurved: true,
              color: AppColors.yellow,
              barWidth: 3,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
