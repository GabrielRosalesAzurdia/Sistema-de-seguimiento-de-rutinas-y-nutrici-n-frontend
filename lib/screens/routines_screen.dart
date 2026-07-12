import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/routine.dart';
import '../services/routine_service.dart';
import 'routine_detail_screen.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final _service = RoutineService();
  late Future<List<Routine>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getRoutines();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rutinas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const Text('Tus programas de ejercicios', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Routine>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final routines = snapshot.data ?? [];
                  if (routines.isEmpty) {
                    return const Center(
                      child: Text('No hay rutinas disponibles todavía',
                          style: TextStyle(color: AppColors.textSecondary)),
                    );
                  }
                  return ListView.separated(
                    itemCount: routines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final routine = routines[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(routine.categoryDisplay,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          subtitle: Text(
                            '${routine.exercises.length} ejercicios · '
                            '${routine.durationLow}-${routine.durationHigh} min · '
                            '${routine.estimatedCalories} calorías',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.yellow, size: 16),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => RoutineDetailScreen(routineId: routine.id)),
                          ),
                        ),
                      );
                    },
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
