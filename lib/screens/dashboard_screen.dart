import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/member.dart';
import '../models/nutrition_plan.dart';
import '../services/member_service.dart';
import '../services/nutrition_service.dart';
import '../services/tracking_service.dart';

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
  final _trackingService = TrackingService();

  Member? _member;
  NutritionPlan? _plan;
  int? _daysToGoal;
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
      ]);
      setState(() {
        _member = results[0] as Member;
        _plan = results[1] as NutritionPlan?;
        _daysToGoal = results[2] as int?;
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
            _MetricsGrid(member: _member, daysToGoal: _daysToGoal),
            const SizedBox(height: 20),
            _NutritionMacros(plan: _plan),
            const SizedBox(height: 20),
            _NutritionSemaphore(
                selected: _todayStatus, onSelect: _markNutrition),
            const SizedBox(height: 20),
            const _TodayRoutineCard(),
          ],
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final Member? member;
  final int? daysToGoal;

  const _MetricsGrid({required this.member, required this.daysToGoal});

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
        _MetricCard(
          label: 'PESO ACTUAL / META',
          value: member?.currentWeightKg != null
              ? '${member!.currentWeightKg} / ${member!.goalWeightKg ?? '-'} kg'
              : '-',
          color: AppColors.yellow,
        ),
        _MetricCard(
          label: 'P. GRASA CORPORAL',
          value: member?.bodyFatPercentage != null
              ? '${member!.bodyFatPercentage}%'
              : '-',
          color: AppColors.orange,
        ),
        _MetricCard(
          label: 'P. AGUA CORPORAL',
          value: member?.bodyWaterPercentage != null
              ? '${member!.bodyWaterPercentage}%'
              : '-',
          color: AppColors.green,
        ),
        _MetricCard(
          label: 'DÍAS PARA META',
          value: daysToGoal != null ? '$daysToGoal d' : '-',
          color: AppColors.yellow,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
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
                _MacroPill('PROTEÍNA', plan?.proteinG, AppColors.green),
                _MacroPill('CARBOHIDRATOS', plan?.carbsG, AppColors.yellow),
                _MacroPill('GRASAS', plan?.fatsG, AppColors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final int? grams;
  final Color color;
  const _MacroPill(this.label, this.grams, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(grams != null ? '${grams}g' : '-',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
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

class _TodayRoutineCard extends StatelessWidget {
  const _TodayRoutineCard();

  @override
  Widget build(BuildContext context) {
    // TODO: reemplazar por la rutina del día real (calendario semanal)
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RUTINA DE HOY',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                SizedBox(height: 4),
                Text('BRAZO Y ESPALDA',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                Text('Aprox 500 calorías · 60 min',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.yellow, size: 18),
          ],
        ),
      ),
    );
  }
}
