import 'package:flutter/material.dart';
import '../models/water_intake_model.dart';
import '../database/database_helper.dart';

class StatsViewModel with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  
  List<WaterIntake> _weeklyData = [];
  bool _isLoading = false;
  String _selectedPeriod = 'Semana';
  String? _userEmail;

  List<WaterIntake> get weeklyData => _weeklyData;
  bool get isLoading => _isLoading;
  String get selectedPeriod => _selectedPeriod;

  // Cargar datos semanales
  Future<void> loadWeeklyData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Obtener usuario actual
      final currentUser = await _db.getCurrentUser();
      
      if (currentUser == null) {
        debugPrint('No hay usuario logueado');
        _createEmptyWeek();
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      _userEmail = currentUser['email'];
      
      // Cargar datos semanales desde SharedPreferences
      final weeklyDataRaw = await _db.getWeeklyStats(_userEmail!);
      
      // Convertir Map a WaterIntake
      _weeklyData = weeklyDataRaw.map((data) {
        return WaterIntake(
          date: DateTime.parse(data['date']),
          milliliters: data['milliliters'] as int,
          dailyGoal: currentUser['dailyGoal'] ?? 2000,
        );
      }).toList();
      
      debugPrint('Loaded ${_weeklyData.length} days of data');
      
    } catch (e) {
      debugPrint('Error loading weekly data: $e');
      _createEmptyWeek();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear semana vacía si no hay datos
  void _createEmptyWeek() {
    final now = DateTime.now();
    _weeklyData = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      _weeklyData.add(WaterIntake(
        date: date,
        milliliters: 0,
        dailyGoal: 2000,
      ));
    }
  }

  // Calcular estadísticas semanales
  Map<String, dynamic> getWeeklyStats() {
    if (_weeklyData.isEmpty) {
      _createEmptyWeek();
    }

    final totalWeekly = _weeklyData.fold<int>(
      0, (sum, intake) => sum + intake.milliliters
    );
    
    final expectedWeekly = _weeklyData.fold<int>(
      0, (sum, intake) => sum + intake.dailyGoal
    );
    
    final averageDaily = _weeklyData.isNotEmpty 
        ? totalWeekly ~/ _weeklyData.length 
        : 0;
    
    final completionRate = expectedWeekly > 0 
        ? (totalWeekly / expectedWeekly) * 100 
        : 0.0;
    
    final daysWithGoal = _weeklyData.where(
      (intake) => intake.milliliters >= intake.dailyGoal
    ).length;

    // Encontrar el mejor día
    WaterIntake? bestDay;
    if (_weeklyData.isNotEmpty) {
      bestDay = _weeklyData.reduce(
        (a, b) => a.milliliters > b.milliliters ? a : b
      );
    }

    return {
      'totalWeekly': totalWeekly,
      'expectedWeekly': expectedWeekly,
      'averageDaily': averageDaily,
      'completionRate': completionRate,
      'bestDay': bestDay,
      'daysWithGoal': daysWithGoal,
      'dailyStats': _getDailyStatsMap(),
    };
  }

  // Obtener datos diarios para el gráfico
  Map<String, int> _getDailyStatsMap() {
    final dailyStats = <String, int>{};
    
    for (var intake in _weeklyData) {
      final dateKey = '${intake.date.day}/${intake.date.month}';
      dailyStats[dateKey] = intake.milliliters;
    }
    
    return dailyStats;
  }

  // Cambiar período de visualización
  void setSelectedPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  // Obtener consumo máximo para escalar el gráfico
  int getMaxConsumption() {
    if (_weeklyData.isEmpty) return 2500;
    
    final max = _weeklyData
        .map((intake) => intake.milliliters)
        .reduce((a, b) => a > b ? a : b);
    
    return max == 0 ? 2500 : max.clamp(2000, 5000);
  }

  // Obtener días de la semana para el gráfico
  List<String> getWeekDays() {
    return ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
  }

  // Obtener nombres completos de los días
  List<String> getFullDayNames() {
    return ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
  }

  // Obtener el índice del día actual para resaltar
  int getTodayIndex() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    for (int i = 0; i < _weeklyData.length; i++) {
      final dataDate = DateTime(
        _weeklyData[i].date.year,
        _weeklyData[i].date.month,
        _weeklyData[i].date.day
      );
      if (dataDate == today) {
        return i;
      }
    }
    
    return DateTime.now().weekday % 7;
  }

  // Reiniciar datos (para testing)
  Future<void> resetData() async {
    _weeklyData = [];
    notifyListeners();
    await loadWeeklyData();
  }

  // Debug: imprimir datos actuales
  void printDebugInfo() {
    debugPrint('=== DEBUG StatsViewModel ===');
    debugPrint('Weekly data length: ${_weeklyData.length}');
    for (var intake in _weeklyData) {
      debugPrint('${intake.date}: ${intake.milliliters}ml / ${intake.dailyGoal}ml');
    }
    debugPrint('==========================');
  }
}