import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/tracking_service.dart';
import 'history_detail_screen.dart';

/// Historial de sesiones de rutina del usuario, por fecha (reemplaza
/// las capturas de pantalla que usaban antes para llevar su propio
/// registro). Solo lectura, paginado (20 por página) contra
/// GET /api/tracking/me/workout-history/.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = TrackingService();
  final _sessions = <WorkoutHistorySession>[];
  int _page = 1;
  bool _hasNext = false;
  bool _loadingMore = false;
  late Future<void> _initialLoad;

  @override
  void initState() {
    super.initState();
    _initialLoad = _loadPage();
  }

  Future<void> _loadPage() async {
    final result = await _service.getWorkoutHistory(page: _page);
    setState(() {
      _sessions.addAll(result.results);
      _hasNext = result.hasNext;
    });
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    _page += 1;
    try {
      await _loadPage();
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: FutureBuilder<void>(
        future: _initialLoad,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('No se pudo cargar el historial',
                  style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          if (_sessions.isEmpty) {
            return const Center(
              child: Text('Todavía no registraste ninguna rutina',
                  style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _sessions.length + (_hasNext ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == _sessions.length) {
                return Center(
                  child: _loadingMore
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(),
                        )
                      : TextButton(
                          onPressed: _loadMore,
                          child: const Text('Cargar más',
                              style: TextStyle(color: AppColors.yellow)),
                        ),
                );
              }
              final session = _sessions[index];
              final date = session.completedAt;
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(session.routineCategoryDisplay,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  subtitle: Text(
                    '${date.day}/${date.month}/${date.year} · '
                    '${session.durationMinutes} min'
                    '${session.caloriesBurned != null ? ' · ${session.caloriesBurned} kcal' : ''}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing:
                      const Icon(Icons.arrow_forward_ios, color: AppColors.yellow, size: 16),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HistoryDetailScreen(session: session),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
