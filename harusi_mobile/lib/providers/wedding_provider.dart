import 'package:flutter/material.dart';
import '../models/wedding.dart';
import '../services/api_service.dart';

class WeddingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Wedding> _weddings = [];
  Wedding? _currentWedding;
  bool _isLoading = false;

  List<Wedding> get weddings => _weddings;
  Wedding? get currentWedding => _currentWedding;
  bool get isLoading => _isLoading;

  Future<void> fetchWeddings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getWeddings();
      _weddings = (response.data as List)
          .map((json) => Wedding.fromJson(json))
          .toList();
    }
    catch (e) {
      print('Error fetching weddings: $e');
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWedding(int id) async {
    try {
      final response = await _apiService.getWedding(id);
      _currentWedding = Wedding.fromJson(response.data);
      notifyListeners();
    }
    catch (e) {
      print('Error fetching wedding: $e');
    }
  }

  Future<bool> createWedding(Wedding wedding) async {
    try {
      await _apiService.createWedding(wedding.toJson());
      await fetchWeddings();
      return true;
    }
    catch (e) {
      print('Error creating wedding: $e');
      return false;
    }
  }

  Future<bool> deleteWedding(int id) async {
    try {
      await _apiService.deleteWedding(id);
      await fetchWeddings();
      return true;
    }
    catch (e) {
      print('Error deleting wedding: $e');
      return false;
    }
  }
}