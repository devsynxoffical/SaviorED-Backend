/// Application-wide constants
class AppConsts {
  // App Info
  static const String appName = 'Savior ED';

  // API
  static const String baseUrl =
      'https://saviored-backend-production.up.railway.app';
  static const Duration apiTimeout = Duration(
    seconds: 60,
  ); // Increased for Railway cold starts

  // Google Sign-In
  static const String googleClientId =
      '529181300486-pgb91al20authinqil85v1ra4avp9enb.apps.googleusercontent.com';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';

  // Pagination
  static const int defaultPageSize = 20;

  // Game Logic
  static const int chestUnlockMinutes = 500; // Minutes required for one chest

  // Private constructor to prevent instantiation
  AppConsts._();
}
