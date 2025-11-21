import 'dart:convert';

class WaterIntake {
  final DateTime date;
  final int milliliters;
  final int dailyGoal;

  WaterIntake({
    required this.date,
    required this.milliliters,
    required this.dailyGoal,
  });

  // Porcentaje limitado al 100%
  double get percentage => (milliliters / dailyGoal * 100).clamp(0.0, 100.0);

  WaterIntake copyWith({
    DateTime? date,
    int? milliliters,
    int? dailyGoal,
  }) {
    return WaterIntake(
      date: date ?? this.date,
      milliliters: milliliters ?? this.milliliters,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }

  // Convertir a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'milliliters': milliliters,
      'dailyGoal': dailyGoal,
    };
  }

  // Convertir a JSON String (para guardar en SharedPreferences)
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Crear desde JSON Map
  factory WaterIntake.fromJson(Map<String, dynamic> json) {
    return WaterIntake(
      date: DateTime.parse(json['date']),
      milliliters: json['milliliters'] ?? 0,
      dailyGoal: json['dailyGoal'] ?? 2000,
    );
  }

  // Crear desde JSON String (desde SharedPreferences)
  factory WaterIntake.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return WaterIntake.fromJson(json);
  }

  @override
  String toString() {
    return 'WaterIntake(date: $date, milliliters: $milliliters, dailyGoal: $dailyGoal)';
  }
}