/// Perfil del miembro tal como lo expone la app (sin correo/teléfono,
/// sin campos de peso/medidas editables: ver backend
/// apps/members/serializers.py -> MemberAppSerializer).
class Member {
  final int id;
  final String fullName;
  final int age;
  final double heightCm;
  final double? currentWeightKg;
  final double? goalWeightKg;
  final double? bodyFatPercentage;
  final double? bodyWaterPercentage;
  final double? leftArmCm;
  final double? rightArmCm;
  final double? waistCm;
  final String fitnessGoal; // GANAR_PESO | PERDER_PESO | MANTENER_PESO | TONIFICAR
  final String activityLevel; // SEDENTARIO | MODERADO | ACTIVO | MUY_ACTIVO
  final double? imc;

  Member({
    required this.id,
    required this.fullName,
    required this.age,
    required this.heightCm,
    this.currentWeightKg,
    this.goalWeightKg,
    this.bodyFatPercentage,
    this.bodyWaterPercentage,
    this.leftArmCm,
    this.rightArmCm,
    this.waistCm,
    required this.fitnessGoal,
    required this.activityLevel,
    this.imc,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) => v == null ? null : double.tryParse(v.toString());
    return Member(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      age: json['age'] ?? 0,
      heightCm: toDouble(json['height_cm']) ?? 0,
      currentWeightKg: toDouble(json['current_weight_kg']),
      goalWeightKg: toDouble(json['goal_weight_kg']),
      bodyFatPercentage: toDouble(json['body_fat_percentage']),
      bodyWaterPercentage: toDouble(json['body_water_percentage']),
      leftArmCm: toDouble(json['left_arm_cm']),
      rightArmCm: toDouble(json['right_arm_cm']),
      waistCm: toDouble(json['waist_cm']),
      fitnessGoal: json['fitness_goal'] ?? 'MANTENER_PESO',
      activityLevel: json['activity_level'] ?? 'MODERADO',
      imc: toDouble(json['imc']),
    );
  }
}
