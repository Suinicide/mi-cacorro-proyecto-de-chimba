import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../database/database_helper.dart';

class AuthViewModel with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Registro
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validaciones
      if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
        _errorMessage = 'Todos los campos son obligatorios';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!_isValidEmail(email)) {
        _errorMessage = 'Correo electrónico inválido';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'La contraseña debe tener al menos 6 caracteres';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Intentar registrar
      final success = await _db.registerUser(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (!success) {
        _errorMessage = 'El usuario ya existe';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Cargar usuario actual
      _currentUser = await _db.getCurrentUser();

      _isLoading = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      _errorMessage = 'Error al registrar: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'Todos los campos son obligatorios';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Intentar login
      final user = await _db.login(
        email: email,
        password: password,
      );

      if (user == null) {
        _errorMessage = 'Credenciales incorrectas';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      _errorMessage = 'Error al iniciar sesión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _db.logout();
    _currentUser = null;
    notifyListeners();
  }

  // Cargar usuario al iniciar la app
  Future<void> loadUser() async {
    try {
      _currentUser = await _db.getCurrentUser();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  // Validar email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Limpiar error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
