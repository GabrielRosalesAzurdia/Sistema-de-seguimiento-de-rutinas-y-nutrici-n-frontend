import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/member.dart';
import '../services/tracking_service.dart';

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
                height: 100,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
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
