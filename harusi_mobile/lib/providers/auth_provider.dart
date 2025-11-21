import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isAuthenticated = false;
  bool _isLoading = true;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;

  AuthProvider() {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await StorageService.getToken();
    final user = await StorageService.getUser();

    if (token != null && user != null) {
      _isAuthenticated = true;
      _user = user;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.login(username, password);
      final token = response.data['token'];

      await StorageService.saveToken(token);

      final userResponse = await _apiService.getUser();
      _user = userResponse.data;
      await StorageService.saveUser(user!);

      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    catch (e){
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearAll();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      await _apiService.register(username, email, password);
      return true;
    }
    catch (e){
      print('Register error: $e');
      return false;
    }
  }
}