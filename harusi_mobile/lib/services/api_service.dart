import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wedding.dart';
import '../models/guest.dart';
import '../models/task.dart';
import '../models/budget.dart';
import '../models/vendor.dart';
import '../models/guest_pledge.dart';
import '../models/timeline.dart';
import '../models/pledge_payment.dart';

class ApiService {
  // IMPORTANT: Change these based on your environment
  // For Android Emulator: use 10.0.2.2
  // For iOS Simulator: use localhost
  // For Physical Device: use your computer's local IP (e.g., 192.168.1.100)
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Token management
  static String? _token;
  
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }
  
  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  // Get headers with authentication
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };
  }
  
  // Error handling helper
  static String _handleError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('error')) {
        return data['error'];
      }
      if (data is Map && data.containsKey('detail')) {
        return data['detail'];
      }
      return 'Request failed with status ${response.statusCode}';
    } catch (e) {
      return 'Request failed: ${response.body}';
    }
  }
  
  // ============ AUTHENTICATION ============
  
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
        'user_type': userType,
      }),
    );
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        await saveToken(data['token']);
      }
      return data;
    } else {
      throw Exception(_handleError(response));
    }
  }
  
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth-token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return data;
      } else {
        throw Exception(_handleError(response));
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }
  
  static Future<void> logout() async {
    try {
      final headers = await _getHeaders();
      await http.post(
        Uri.parse('$baseUrl/auth/logout/'),
        headers: headers,
      );
    } finally {
      await clearToken();
    }
  }
  
  // ============ WEDDINGS ============
  
  static Future<List<Wedding>> getWeddings() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/weddings/'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Wedding.fromJson(json)).toList();
    } else {
      throw Exception(_handleError(response));
    }
  }
  
  static Future<Wedding> getWedding(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/weddings/$id/'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return Wedding.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_handleError(response));
    }
  }
  
  static Future<Wedding> createWedding(Wedding wedding) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/weddings/'),
      headers: headers,
      body: jsonEncode(wedding.toJson()),
    );
    
    if (response.statusCode == 201) {
      return Wedding.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_handleError(response));
    }
  }
  
  static Future<Wedding> updateWedding(int id, Wedding wedding) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/weddings/$id/'),
      headers: headers,
      body: jsonEncode(wedding.toJson()),
    );
    
    if (response.statusCode == 200) {
      return Wedding.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_handleError(response));
    }
  }
  
  static Future<void> deleteWedding(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/weddings/$id/'),
      headers: headers,
    );
    
    if (response.statusCode != 204) {
      throw Exception(_handleError(response));
    }
  }
  
  // ============ GUESTS ============
  
  static Future<List<Guest>> getGuests(int weddingId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/weddings/$weddingId/guests/'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Guest.fromJson(json)).toList();
    } else {
      throw Exception(_handleError(response));
    }
  }
  
  static Future<Guest> createGuest(int weddingId, Guest guest) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/weddings/$weddingId/guests/'),
      headers: headers,
      body: jsonEncode(guest.toJson()),
    );
    
    if (response.statusCode == 201) {
      return Guest.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_handleError(response));
    }
  }
  
  static Future<Guest> updateGuest(int weddingId, int id, Guest guest) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/weddings/$weddingId/guests/$id/'),
      headers: headers,
      body: jsonEncode(guest.toJson()),
    );
    
    if (response.statusCode == 200) {
      return Guest.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_handleError(response));
    }
  }
  
  static Future<void> deleteGuest(int weddingId, int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/weddings/$weddingId/guests/$id/'),
      headers: headers,
    );
    
    if (response.statusCode != 204) {
      throw Exception(_handleError(response));
    }
  }
  
  // ============ TASKS ============
  
  static Future<List<Task>> getTasks(int weddingId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/weddings/$weddingId/tasks/'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception(_handleError(response));
    }
  }
  
static Future<Task> createTask(int weddingId, Task task) async {
  final headers = await _getHeaders();
  
  // Don't send 'wedding' field - it's read-only and set by backend
  final body = {
    'title': task.title,
    if (task.description != null && task.description!.isNotEmpty) 
      'description': task.description,
    'priority': task.priority,
    'status': task.status,
    if (task.dueDate != null) 
      'due_date': task.dueDate!.toIso8601String().split('T')[0],
    if (task.assignedTo != null && task.assignedTo!.isNotEmpty) 
      'assigned_to': task.assignedTo,
    if (task.cost != null) 
      'cost': task.cost,
  };
  
  print('Creating task for wedding $weddingId');
  print('Request body: ${jsonEncode(body)}');
  
  final response = await http.post(
    Uri.parse('$baseUrl/weddings/$weddingId/tasks/'),
    headers: headers,
    body: jsonEncode(body),
  );
  
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  
  if (response.statusCode == 201) {
    return Task.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(_handleError(response));
  }
}

  static Future<Task> updateTask(int weddingId, int id, Task task) async {
  final headers = await _getHeaders();
  
  // Don't send 'wedding' field - it's read-only
  // Only include non-null values
  final body = {
    'title': task.title,
    if (task.description != null && task.description!.isNotEmpty) 
      'description': task.description,
    'priority': task.priority,
    'status': task.status,
    if (task.dueDate != null) 
      'due_date': task.dueDate!.toIso8601String().split('T')[0],
    if (task.assignedTo != null && task.assignedTo!.isNotEmpty) 
      'assigned_to': task.assignedTo,
    if (task.cost != null) 
      'cost': task.cost,
  };
  
  print('Updating task $id for wedding $weddingId');
  print('Request body: ${jsonEncode(body)}');
  
  final response = await http.put(
    Uri.parse('$baseUrl/weddings/$weddingId/tasks/$id/'),
    headers: headers,
    body: jsonEncode(body),
  );
  
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  
  if (response.statusCode == 200) {
    return Task.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(_handleError(response));
  }
}
  
  static Future<void> deleteTask(int weddingId, int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/weddings/$weddingId/tasks/$id/'),
      headers: headers,
    );
    
    if (response.statusCode != 204) {
      throw Exception(_handleError(response));
    }
  }
  
  // ============ BUDGET ============
  
  static Future<List<Budget>> getBudgetItems(int weddingId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/weddings/$weddingId/budget/'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Budget.fromJson(json)).toList();
    } else {
      throw Exception(_handleError(response));
    }
  }
  
  static Future<Budget> createBudgetItem(int weddingId, Budget budget) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/weddings/$weddingId/budget/'),
      headers: headers,
      body: jsonEncode(budget.toJson()),
    );
    
    if (response.statusCode == 201) {
      return Budget.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_handleError(response));
    }
  }
  
  static Future<Budget> updateBudgetItem(int weddingId, int id, Budget budget) async {
    final headers = await _getHeaders();
    
    final body = {
      'category': budget.category,
      'item_name': budget.itemName,
      'estimated_cost': budget.estimatedCost,
      if (budget.actualCost != null) 'actual_cost': budget.actualCost,
      if (budget.notes != null && budget.notes!.isNotEmpty) 'notes': budget.notes,
    };
    
    print('Updating budget item $id for wedding $weddingId');
    print('Request body: ${jsonEncode(body)}');
    
    final response = await http.put(
      Uri.parse('$baseUrl/weddings/$weddingId/budget/$id/'),
      headers: headers,
      body: jsonEncode(body),
    );
    
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      return Budget.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_handleError(response));
    }
  }

  static Future<void> deleteBudgetItem(int weddingId, int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/weddings/$weddingId/budget/$id/'),
      headers: headers,
    );
    
    if (response.statusCode != 204) {
      throw Exception(_handleError(response));
    }
  }
  // ============ VENDORS ============
  static Future<List<Vendor>> getVendors(int weddingId) async {
  final headers = await _getHeaders();
  final response = await http.get(
    Uri.parse('$baseUrl/weddings/$weddingId/vendors/'),
    headers: headers,
  );
  
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => Vendor.fromJson(json)).toList();
  } else {
    throw Exception(_handleError(response));
  }
}

static Future<Vendor> createVendor(int weddingId, Vendor vendor) async {
  final headers = await _getHeaders();
  final response = await http.post(
    Uri.parse('$baseUrl/weddings/$weddingId/vendors/'),
    headers: headers,
    body: jsonEncode(vendor.toJson()),
  );
  
  if (response.statusCode == 201) {
    return Vendor.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(_handleError(response));
  }
}

static Future<Vendor> updateVendor(int weddingId, int vendorId, Vendor vendor) async {
  final headers = await _getHeaders();
  final response = await http.put(
    Uri.parse('$baseUrl/weddings/$weddingId/vendors/$vendorId/'),
    headers: headers,
    body: jsonEncode(vendor.toJson()),
  );
  
  if (response.statusCode == 200) {
    return Vendor.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(_handleError(response));
  }
}

static Future<void> deleteVendor(int weddingId, int vendorId) async {
  final headers = await _getHeaders();
  final response = await http.delete(
    Uri.parse('$baseUrl/weddings/$weddingId/vendors/$vendorId/'),
    headers: headers,
  );
  
  if (response.statusCode != 204 && response.statusCode != 200) {
    throw Exception(_handleError(response));
  }
}
  
  // ============ GUEST PLEDGES ============
  
  static Future<List<GuestPledge>> getPledges(int weddingId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/weddings/$weddingId/pledges/'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => GuestPledge.fromJson(json)).toList();
    } else {
      throw Exception(_handleError(response));
    }
  }
  
  static Future<GuestPledge> createPledge(int weddingId, GuestPledge pledge) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/weddings/$weddingId/pledges/'),
      headers: headers,
      body: jsonEncode(pledge.toJson()),
    );
    
    if (response.statusCode == 201) {
      return GuestPledge.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_handleError(response));
    }
  }

  // Record pledge payment
  static Future<PledgePayment> recordPledgePayment(
    int weddingId, 
    int pledgeId, 
    PledgePayment payment
  ) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/weddings/$weddingId/pledges/$pledgeId/payments/'),
      headers: headers,
      body: jsonEncode(payment.toJson()),
    );

    if (response.statusCode == 201) {
      return PledgePayment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(_handleError(response));
    }
  }
  
  // ============ TIMELINE ============
// Add these methods to your ApiService class

static Future<List<Timeline>> getTimelineEvents(int weddingId) async {
  final headers = await _getHeaders();
  final response = await http.get(
    Uri.parse('$baseUrl/weddings/$weddingId/timeline/'),
    headers: headers,
  );
  
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => Timeline.fromJson(json)).toList();
  } else {
    throw Exception(_handleError(response));
  }
}

static Future<Timeline> createTimelineEvent(int weddingId, Timeline timeline) async {
  final headers = await _getHeaders();
  final response = await http.post(
    Uri.parse('$baseUrl/weddings/$weddingId/timeline/'),
    headers: headers,
    body: jsonEncode(timeline.toJson()),
  );
  
  if (response.statusCode == 201) {
    return Timeline.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(_handleError(response));
  }
}

static Future<Timeline> updateTimelineEvent(int weddingId, int eventId, Timeline timeline) async {
  final headers = await _getHeaders();
  final response = await http.put(
    Uri.parse('$baseUrl/weddings/$weddingId/timeline/$eventId/'),
    headers: headers,
    body: jsonEncode(timeline.toJson()),
  );
  
  if (response.statusCode == 200) {
    return Timeline.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(_handleError(response));
  }
}

static Future<void> deleteTimelineEvent(int weddingId, int eventId) async {
  final headers = await _getHeaders();
  final response = await http.delete(
    Uri.parse('$baseUrl/weddings/$weddingId/timeline/$eventId/'),
    headers: headers,
  );
  
  if (response.statusCode != 204 && response.statusCode != 200) {
    throw Exception(_handleError(response));
  }
}

static Future<void> toggleTimelineEventCompletion(int weddingId, int eventId) async {
  final headers = await _getHeaders();
  final response = await http.post(
    Uri.parse('$baseUrl/weddings/$weddingId/timeline/$eventId/toggle_completed/'),
    headers: headers,
  );
  
  if (response.statusCode != 200) {
    throw Exception(_handleError(response));
  }
}
}