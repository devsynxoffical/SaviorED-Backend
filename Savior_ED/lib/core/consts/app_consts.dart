/// Application-wide constants
class AppConsts {
  // App Info
  static const String appName = 'Savior ED';
  
  // API
  static const String baseUrl = 'http://localhost:5000'; // Change to your server URL
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Private constructor to prevent instantiation
  AppConsts._();
}

