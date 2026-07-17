import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/member.dart';
import '../models/nutrition_plan.dart';
import '../models/routine.dart';
import '../services/member_service.dart';
import '../services/nutrition_service.dart';
import '../services/routine_service.dart';
import '../services/tracking_service.dart';
import '../widgets/macro_pill.dart';
import '../widgets/metric_card.dart';
import '../widgets/weight_chart.dart';
import 'routine_detail_screen.dart';

/// Pantalla 'Inicio': réplica funcional del mockup (página 3):
/// peso actual/meta, % grasa y agua corporal (calculados por el
/// sistema), días para meta (ML), racha, macros del día, semáforo de
/// nutrición diario, calorías quemadas totales y rutina de hoy.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _memberService = MemberService();
  final _nutritionService = NutritionService();
  final _routineService = RoutineService();
  final _trackingService = TrackingService();

  Member? _member;
  NutritionPlan? _plan;
  int? _daysToGoal;
  TrackingSummary? _summary;
  List<WeightPoint> _weightHistory = [];
  Routine? _todayRoutine;
  NutritionCheckStatus? _todayStatus;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _memberService.getMyProfile(),
        _nutritionService.getMyCurrentPlan(),
        _trackingService.getDaysToGoal(),
        _trackingService.getSummary(),
        _trackingService.getWeightHistory(),
        _routineService.getTodayRoutine(),
      ]);
      setState(() {
        _member = results[0] as Member;
        _plan = results[1] as NutritionPlan?;
        _daysToGoal = results[2] as int?;
        _summary = results[3] as TrackingSummary?;
        _weightHistory = results[4] as List<WeightPoint>;
        _todayRoutine = results[5] as Routine?;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _markNutrition(NutritionCheckStatus status) async {
    setState(() => _todayStatus = status);
    await _nutritionService.registerDailyCheck(status);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('¡Tu mejor proyecto\neres tú!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(
                'Bienvenido de nuevo, ${_member?.fullName.split(' ').first ?? ''}',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            WeightChartCard(member: _member, history: _weightHistory),
            const SizedBox(height: 20),
            _MetricsGrid(
                member: _member, daysToGoal: _daysToGoal, summary: _summary),
            const SizedBox(height: 20),
            _NutritionMacros(plan: _plan),
            const SizedBox(height: 20),
            _NutritionSemaphore(
                selected: _todayStatus, onSelect: _markNutrition),
            const SizedBox(height: 20),
            _TotalCaloriesCard(summary: _summary),
            const SizedBox(height: 20),
            _TodayRoutineCard(routine: _todayRoutine),
          ],
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final Member? member;
  final int? daysToGoal;
  final TrackingSummary? summary;

  const _MetricsGrid(
      {required this.member, required this.daysToGoal, required this.summary});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        MetricCard(
          label: 'P. GRASA CORPORAL',
          value: member?.bodyFatPercentage != null
              ? '${member!.bodyFatPercentage}%'
              : '-',
          color: AppColors.orange,
        ),
        MetricCard(
          label: 'P. AGUA CORPORAL',
          value: member?.bodyWaterPercentage != null
              ? '${member!.bodyWaterPercentage}%'
              : '-',
          color: AppColors.green,
        ),
        MetricCard(
          label: 'DÍAS PARA META',
          value: daysToGoal != null ? '$daysToGoal d' : '-',
          color: AppColors.yellow,
        ),
        MetricCard(
          label: 'RACHA',
          value: summary != null ? '${summary!.streakDays} d' : '-',
          color: AppColors.orange,
        ),
      ],
    );
  }
}

class _TotalCaloriesCard extends StatelessWidget {
  final TrackingSummary? summary;
  const _TotalCaloriesCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CALORÍAS QUEMADAS EN TOTAL',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              summary != null ? '${summary!.totalCaloriesBurned} CAL' : '-',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.yellow),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionMacros extends StatelessWidget {
  final NutritionPlan? plan;
  const _NutritionMacros({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('NUTRICIÓN DIARIA',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MacroPill('PROTEÍNA', plan?.proteinG, AppColors.orange),
                MacroPill('CARBOHIDRATOS', plan?.carbsG, AppColors.yellow),
                MacroPill('GRASAS', plan?.fatsG, AppColors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionSemaphore extends StatelessWidget {
  final NutritionCheckStatus? selected;
  final ValueChanged<NutritionCheckStatus> onSelect;

  const _NutritionSemaphore({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SEGUIMIENTO DE NUTRICIÓN DIARIO',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: NutritionCheckStatus.values.map((status) {
                final isSelected = selected == status;
                final color = switch (status) {
                  NutritionCheckStatus.hecho => AppColors.green,
                  NutritionCheckStatus.parcialmente => AppColors.yellow,
                  NutritionCheckStatus.seMeFue => AppColors.danger,
                };
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => onSelect(status),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color
                              : color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          status.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : color,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rutina de hoy real, según el calendario semanal por género
/// (GET /api/routines/me/today/, ver RoutineService.getTodayRoutine).
/// Al tocarla, navega al detalle — igual que desde el listado de
/// Rutinas. Si es día de descanso (o el miembro no tiene género
/// asignado todavía), muestra un mensaje en vez de la tarjeta.
class _TodayRoutineCard extends StatelessWidget {
  final Routine? routine;
  const _TodayRoutineCard({required this.routine});

  @override
  Widget build(BuildContext context) {
    if (routine == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Hoy no tienes una rutina asignada. Consulta con tu coach.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RoutineDetailScreen(routineId: routine!.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RUTINA DE HOY',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(routine!.categoryDisplay.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  Text(
                      'Aprox ${routine!.estimatedCalories} calorías · '
                      '${routine!.durationLow}-${routine!.durationHigh} min',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, color: AppColors.yellow, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
