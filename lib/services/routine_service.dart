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
}
