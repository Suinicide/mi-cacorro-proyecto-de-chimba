import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/water_intake_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // ========== USUARIOS ==========
  
  Future<bool> registerUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Verificar si el usuario ya existe
    final existingUser = prefs.getString('user_$email');
    if (existingUser != null) {
      return false;
    }
    
    // Guardar usuario
    final userData = {
      'email': email,
      'password': password,
      'fullName': fullName,
      'dailyGoal': 2000,
      'registeredAt': DateTime.now().toIso8601String(),
    };
    
    await prefs.setString('user_$email', jsonEncode(userData));
    await prefs.setString('current_user', email);
    
    return true;
  }
  
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_$email');
    
    if (userData == null) return null;
    
    final user = jsonDecode(userData);
    
    if (user['password'] == password) {
      await prefs.setString('current_user', email);
      return user;
    }
    
    return null;
  }
  
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user');
    
    if (email == null) return null;
    
    final userData = prefs.getString('user_$email');
    if (userData == null) return null;
    
    return jsonDecode(userData);
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }
  
  // ========== CONSUMO DE AGUA ==========
  
  Future<void> saveWaterIntake({
    required String userEmail,
    required DateTime date,
    required int milliliters,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _formatDate(date);
    final key = 'water_${userEmail}_$dateKey';
    
    final data = {
      'date': date.toIso8601String(),
      'milliliters': milliliters,
      'userEmail': userEmail,
    };
    
    await prefs.setString(key, jsonEncode(data));
  }
  
  Future<int> getWaterIntake({
    required String userEmail,
    required DateTime date,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = _formatDate(date);
    final key = 'water_${userEmail}_$dateKey';
    
    final data = prefs.getString(key);
    if (data == null) return 0;
    
    final decoded = jsonDecode(data);
    return decoded['milliliters'] ?? 0;
  }
  
  Future<List<Map<String, dynamic>>> getWeeklyStats(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final weeklyData = <Map<String, dynamic>>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = _formatDate(date);
      final key = 'water_${userEmail}_$dateKey';
      
      final data = prefs.getString(key);
      
      if (data != null) {
        weeklyData.add(jsonDecode(data));
      } else {
        weeklyData.add({
          'date': date.toIso8601String(),
          'milliliters': 0,
          'userEmail': userEmail,
        });
      }
    }
    
    return weeklyData;
  }
  
  // ========== MÉTODOS LEGACY (para compatibilidad) ==========
  
  // Estos métodos mantienen compatibilidad con código antiguo
  Future<void> insertWaterIntake(WaterIntake intake) async {
    final user = await getCurrentUser();
    if (user == null) return;
    
    await saveWaterIntake(
      userEmail: user['email'],
      date: intake.date,
      milliliters: intake.milliliters,
    );
  }
  
  Future<void> updateWaterIntake(WaterIntake intake) async {
    await insertWaterIntake(intake);
  }
  
  Future<WaterIntake?> getTodayWaterIntake() async {
    final user = await getCurrentUser();
    if (user == null) return null;
    
    final milliliters = await getWaterIntake(
      userEmail: user['email'],
      date: DateTime.now(),
    );
    
    return WaterIntake(
      date: DateTime.now(),
      milliliters: milliliters,
      dailyGoal: user['dailyGoal'] ?? 2000,
    );
  }
  
  Future<List<WaterIntake>> getWeeklyWaterIntake() async {
    final user = await getCurrentUser();
    if (user == null) return [];
    
    final weeklyData = await getWeeklyStats(user['email']);
    
    return weeklyData.map((data) {
      return WaterIntake(
        date: DateTime.parse(data['date']),
        milliliters: data['milliliters'] ?? 0,
        dailyGoal: user['dailyGoal'] ?? 2000,
      );
    }).toList();
  }
  
  // ========== ALARMAS ==========
  
  Future<void> saveAlarms(String userEmail, List<Map<String, dynamic>> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('alarms_$userEmail', jsonEncode(alarms));
  }
  
  Future<List<Map<String, dynamic>>> getAlarms(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('alarms_$userEmail');
    
    if (data == null) {
      return [
        {'id': '1', 'title': 'Me acuesto', 'time': '22:00', 'enabled': true},
        {'id': '2', 'title': 'Me levanto', 'time': '07:00', 'enabled': true},
        {'id': '3', 'title': 'Recordatorio', 'time': '1h 30min', 'enabled': true},
      ];
    }
    
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }
  
  // ========== UTILIDADES ==========
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}