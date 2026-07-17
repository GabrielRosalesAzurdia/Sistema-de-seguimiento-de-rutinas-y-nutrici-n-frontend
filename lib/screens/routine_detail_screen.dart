import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/routine.dart';
import '../services/routine_service.dart';
import 'log_routine_screen.dart';

/// Detalle de una rutina: solo muestra el ORDEN de los ejercicios (no
/// se marca completado por ejercicio individual, ver Cuestionario
/// Requerimientos, B5: "la app no debe marcar completado por
/// ejercicio, solo mostrar el orden").
class RoutineDetailScreen extends StatefulWidget {
  final int routineId;
  const RoutineDetailScreen({super.key, required this.routineId});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  final _service = RoutineService();
  late Future<Routine> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getRoutineDetail(widget.routineId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<Routine>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final routine = snapshot.data;
          if (routine == null) {
            return const Center(child: Text('No se pudo cargar la rutina'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(routine.categoryDisplay,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const Text(
                    'La rutina está formada por los siguientes ejercicios',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: routine.exercises.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: AppColors.surface),
                    itemBuilder: (context, index) {
                      final item = routine.exercises[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.yellow,
                          foregroundColor: Colors.black,
                          child: Text('${item.order}'),
                        ),
                        title: Text(item.exercise.name,
                            style:
                                const TextStyle(color: AppColors.textPrimary)),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => LogRoutineScreen(routine: routine)),
                      ),
                      child: const Text('Iniciar'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
