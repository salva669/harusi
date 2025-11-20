class AppConfig{
  //API Configuration
  //using 10.0.2.2 for android emulator
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  //APP information
  static const String appName = 'Harusi';
  static const String appVersion = '1.0.0';

  //storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  //timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}