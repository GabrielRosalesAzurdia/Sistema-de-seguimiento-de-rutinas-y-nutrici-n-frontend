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
              SizedBox(
                height: 130,
                child: LineChart(
                  LineChartData(
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
                          getTitlesWidget: (value, meta) {
                            final index = value.round();
                            if (index < 0 || index >= history.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _monthAbbr[history[index].date.month],
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
                          for (var i = 0; i < history.length; i++)
                            FlSpot(i.toDouble(), history[i].weightKg),
                        ],
                        isCurved: true,
                        color: AppColors.yellow,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
