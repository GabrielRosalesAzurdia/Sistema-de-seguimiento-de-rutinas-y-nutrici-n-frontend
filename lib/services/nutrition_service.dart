import '../core/api_client.dart';
import '../models/nutrition_plan.dart';

class NutritionService {
  final _client = ApiClient.instance;

  Future<NutritionPlan?> getMyCurrentPlan() async {
    try {
      final response = await _client.dio.get('/nutrition/me/current-plan/');
      return NutritionPlan.fromJson(response.data);
    } catch (_) {
      // Puede no existir un plan aprobado todavía (pendiente de revisión
      // por el coach, ver NutritionPlanStatus.PENDING_REVIEW).
      return null;
    }
  }

  Future<void> registerDailyCheck(NutritionCheckStatus status, {DateTime? date}) async {
    final day = (date ?? DateTime.now()).toIso8601String().split('T').first;
    await _client.dio.post('/tracking/nutrition-logs/', data: {
      'date': day,
      'status': status.apiValue,
    });
  }
}
