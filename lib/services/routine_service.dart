import '../core/api_client.dart';
import '../models/routine.dart';

class RoutineService {
  final _client = ApiClient.instance;

  Future<List<Routine>> getRoutines() async {
    final response = await _client.dio.get('/routines/');
    final results = response.data['results'] ?? response.data;
    return (results as List).map((r) => Routine.fromJson(r)).toList();
  }

  Future<Routine> getRoutineDetail(int id) async {
    final response = await _client.dio.get('/routines/$id/');
    return Routine.fromJson(response.data);
  }

  /// Rutina de hoy según el calendario semanal por género del miembro
  /// (tarjeta 'RUTINA DE HOY' del dashboard). Devuelve null si el
  /// miembro no tiene género asignado o si hoy es día de descanso.
  Future<Routine?> getTodayRoutine() async {
    final response = await _client.dio.get('/routines/me/today/');
    if (response.statusCode == 204 || response.data == null) return null;
    return Routine.fromJson(response.data);
  }
}
