import 'package:flutter/material.dart';
import '../models/water_intake_model.dart';
import '../database/database_helper.dart';

class HomeViewModel with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  
  WaterIntake _waterIntake = WaterIntake(
    date: DateTime.now(),
    milliliters: 0,
    dailyGoal: 2000,
  );

  bool _isLoading = false;
  String? _userEmail; // Email del usuario actual

  WaterIntake get waterIntake => _waterIntake;
  double get percentage => _waterIntake.percentage;
  bool get isLoading => _isLoading;

  // Cargar datos del usuario actual
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Obtener usuario actual
      final currentUser = await _db.getCurrentUser();
      
      if (currentUser == null) {
        // No hay usuario logueado
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      _userEmail = currentUser['email'];
      
      // Cargar consumo del día actual
      final todayMilliliters = await _db.getWaterIntake(
        userEmail: _userEmail!,
        date: DateTime.now(),
      );
      
      _waterIntake = WaterIntake(
        date: DateTime.now(),
        milliliters: todayMilliliters,
        dailyGoal: currentUser['dailyGoal'] ?? 2000,
      );
      
    } catch (e) {
      debugPrint('Error loading data: $e');
      _waterIntake = WaterIntake(
        date: DateTime.now(),
        milliliters: 0,
        dailyGoal: 2000,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar agua
  Future<void> addWater(int amount) async {
    if (_userEmail == null) return;
    
    // Calcular el nuevo total
    int newTotal = _waterIntake.milliliters + amount;
    
    // Establecer límite máximo (150% de la meta)
    int maxAllowed = (_waterIntake.dailyGoal * 1.5).toInt();
    newTotal = newTotal.clamp(0, maxAllowed);
    
    _waterIntake = _waterIntake.copyWith(milliliters: newTotal);
    
    // Guardar en SharedPreferences
    await _db.saveWaterIntake(
      userEmail: _userEmail!,
      date: DateTime.now(),
      milliliters: newTotal,
    );
    
    notifyListeners();
  }

  // Reiniciar el día
  Future<void> resetDaily() async {
    if (_userEmail == null) return;
    
    _waterIntake = _waterIntake.copyWith(milliliters: 0);
    
    await _db.saveWaterIntake(
      userEmail: _userEmail!,
      date: DateTime.now(),
      milliliters: 0,
    );
    
    notifyListeners();
  }

  // Cambiar meta diaria
  Future<void> updateGoal(int newGoal) async {
    _waterIntake = _waterIntake.copyWith(dailyGoal: newGoal);
    
    // Aquí también deberías actualizar el dailyGoal del usuario en SharedPreferences
    // Lo implementamos después si lo necesitas
    
    notifyListeners();
  }

  // Obtener estadísticas semanales
  Future<Map<String, dynamic>> getWeeklyStats() async {
    if (_userEmail == null) {
      return {
        'dailyStats': <String, int>{},
        'totalWeekly': 0,
        'expectedWeekly': 14000,
        'weeklyData': <Map<String, dynamic>>[],
      };
    }
    
    final weeklyData = await _db.getWeeklyStats(_userEmail!);
    
    // Procesar datos para el gráfico
    final dailyStats = <String, int>{};
    int totalWeekly = 0;
    
    for (var intake in weeklyData) {
      final date = DateTime.parse(intake['date']);
      final dateKey = '${date.day}/${date.month}';
      final milliliters = intake['milliliters'] as int;
      
      dailyStats[dateKey] = milliliters;
      totalWeekly += milliliters;
    }
    
    return {
      'dailyStats': dailyStats,
      'totalWeekly': totalWeekly,
      'expectedWeekly': _waterIntake.dailyGoal * 7,
      'weeklyData': weeklyData,
    };
  }
}