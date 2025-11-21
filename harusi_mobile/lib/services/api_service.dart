import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectionTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    //add interceptor for token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Token $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        print('API Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  //Auth
  Future<Response> login(String username, String password) {
    return _dio.post('/auth-token/', data: {
      'username': username,
      'password': password,
    });
  }

  Future<Response> register(String username, String email, String password) {
    return _dio.post('/register/', data: {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  Future<Response> getUser() {
    return _dio.get('/user/');
  }

  //Weddings
  Future<Response> getWeddings() {
    return _dio.get('/weddings/');
  }

  Future<Response> getWedding(int id) {
    return _dio.get('/weddings/$id/');
  }

  Future<Response> createWedding(Map<String, dynamic> data) {
    return _dio.post('/weddings/', data: data);
  }

  Future <Response> updateWedding(int id, Map<String, dynamic> data) {
    return _dio.put('/weddings/$id/', data: data);
  }

  Future<Response> deleteWedding(int id){
    return _dio.delete('/weddings/$id/');
  }

  //Guests
  Future<Response> getGuests(int weddingId) {
    return _dio.get('/weddings/$weddingId/guests/');
  }

  Future<Response> createGuest(int weddingId, Map<String, dynamic> data) {
    return _dio.post('/weddings/$weddingId/guests/', data: data);
  }

  Future<Response>updateGuest(int weddingId, int guestId, Map<String, dynamic> data) {
    return _dio.put('/weddings/$weddingId/guests/$guestId', data: data);
  }

  Future<Response>deleteGuest(int weddingId, int guestId) {
    return _dio.delete('/weddings/$weddingId/guests/$guestId');
  }

  //Pledges
  Future<Response> getPledges(int weddingId) {
    return _dio.get('/weddings/$weddingId/pledges/');
  }

  Future<Response> createPledge(int weddingId, Map<String, dynamic> data) {
    return _dio.post('/weddings/$weddingId/pledges/', data: data);
  }

  Future<Response> updatePledge(int weddingId, int pledgeId, Map<String, dynamic> data) {
    return _dio.put('/weddings/$weddingId/pledges/$pledgeId/', data: data);
  }

  Future<Response> deletePledge(int weddingId, int pledgeId) {
    return _dio.delete('/weddings/$weddingId/pledges/$pledgeId/');
  }

  Future<Response> getPledgeSummary(int weddingId) {
    return _dio.get('/weddings/$weddingId/pledges/summary/');
  }

  Future<Response> recordPayment(int weddingId, int pledgeId, Map<String, dynamic> data) {
    return _dio.post('/weddings/$weddingId/pledges/$pledgeId/record_payment/', data: data);
  }

  // Tasks
  Future<Response> getTasks(int weddingId) {
    return _dio.get('/weddings/$weddingId/tasks/');
  }

  Future<Response> createTask(int weddingId, Map<String, dynamic> data) {
    return _dio.post('/weddings/$weddingId/tasks/', data: data);
  }

  // Budget
  Future<Response> getBudgetItems(int weddingId) {
    return _dio.get('/weddings/$weddingId/budget/');
  }

  Future<Response> createBudgetItem(int weddingId, Map<String, dynamic> data) {
    return _dio.post('/weddings/$weddingId/budget/', data: data);
  }
}