import 'package:shared_preferences/shared_preferences.dart';
import '../consts/app_consts.dart';

/// Storage Service for handling local storage
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  /// Initialize storage service
  Future<void> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  /// Ensure storage is initialized
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  /// Save string value
  Future<bool> saveString(String key, String value) async {
    await ensureInitialized();
    if (_prefs == null) return false;
    return await _prefs!.setString(key, value);
  }

  /// Get string value
  String? getString(String key) {
    if (!_isInitialized) return null;
    return _prefs?.getString(key);
  }

  /// Save int value
  Future<bool> saveInt(String key, int value) async {
    await ensureInitialized();
    if (_prefs == null) return false;
    return await _prefs!.setInt(key, value);
  }

  /// Get int value
  int? getInt(String key) {
    if (!_isInitialized) return null;
    return _prefs?.getInt(key);
  }

  /// Save bool value
  Future<bool> saveBool(String key, bool value) async {
    await ensureInitialized();
    if (_prefs == null) return false;
    return await _prefs!.setBool(key, value);
  }

  /// Get bool value
  bool? getBool(String key) {
    if (!_isInitialized) return null;
    return _prefs?.getBool(key);
  }

  /// Remove value
  Future<bool> remove(String key) async {
    await ensureInitialized();
    if (_prefs == null) return false;
    return await _prefs!.remove(key);
  }

  /// Clear all data
  Future<bool> clear() async {
    await ensureInitialized();
    if (_prefs == null) return false;
    return await _prefs!.clear();
  }

  /// Save auth token
  Future<bool> saveToken(String token) async {
    return await saveString(AppConsts.tokenKey, token);
  }

  /// Get auth token
  String? getToken() {
    return getString(AppConsts.tokenKey);
  }

  /// Remove auth token
  Future<bool> removeToken() async {
    return await remove(AppConsts.tokenKey);
  }
}

