import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/tracking_service.dart';
import '../widgets/exercise_progress_chart.dart';

/// Progreso de peso final para un ejercicio puntual, a través de todas
/// las sesiones históricas donde se registró (se abre desde el detalle
/// de una sesión en la pantalla 'Historial').
class ExerciseProgressScreen extends StatefulWidget {
  final int exerciseId;
  final String exerciseName;

  const ExerciseProgressScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  @override
  State<ExerciseProgressScreen> createState() => _ExerciseProgressScreenState();
}

class _ExerciseProgressScreenState extends State<ExerciseProgressScreen> {
  final _service = TrackingService();
  late Future<List<ExerciseProgressPoint>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getExerciseProgress(widget.exerciseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.exerciseName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<ExerciseProgressPoint>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final points = snapshot.data;
            if (points == null) {
              return const Center(
                child: Text('No se pudo cargar el progreso',
                    style: TextStyle(color: AppColors.textSecondary)),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Peso final registrado por sesión',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ExerciseProgressChart(points: points),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
