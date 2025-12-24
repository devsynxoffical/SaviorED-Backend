import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../services/storage_service.dart';
import '../../../services/api_service.dart';
import '../models/user_model.dart';

/// Authentication ViewModel using ChangeNotifier for Provider
class AuthViewModel extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final ApiService _apiService = ApiService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Initialize and restore user session
  Future<void> initialize() async {
    print('AuthViewModel: initialize called');
    if (_isInitialized) {
      print('AuthViewModel: Already initialized');
      return;
    }

    try {
      print('AuthViewModel: Initializing StorageService');
      await _storageService.ensureInitialized();
      print('AuthViewModel: StorageService initialized');
      await checkAuthStatus();
      print('AuthViewModel: Auth status checked');
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('AuthViewModel: Error initializing: $e');
      _setError(e.toString());
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _apiService.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success'] == true) {
        final userData = response.data['user'];
        final token = response.data['token'];

        _user = UserModel(
          id: userData['id'],
          email: userData['email'],
          name: userData['name'],
          avatar: userData['avatar'],
        );

        await _storageService.saveToken(token);
        await _storageService.saveString('user_id', _user!.id);
        await _storageService.saveString('user_email', _user!.email);
        if (_user!.name != null) {
          await _storageService.saveString('user_name', _user!.name!);
        }
        await _storageService.saveBool('is_authenticated', true);

        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response.data['message'] ?? 'Login failed');
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 
          e.message ?? 
          'Login failed. Please check your credentials.';
      _setError(errorMessage);
      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Register user
  Future<bool> register(String email, String password, String name) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _apiService.post('/api/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
      });

      if (response.data['success'] == true) {
        final userData = response.data['user'];
        final token = response.data['token'];

        _user = UserModel(
          id: userData['id'],
          email: userData['email'],
          name: userData['name'],
          avatar: userData['avatar'],
        );

        await _storageService.saveToken(token);
        await _storageService.saveString('user_id', _user!.id);
        await _storageService.saveString('user_email', _user!.email);
        if (_user!.name != null) {
          await _storageService.saveString('user_name', _user!.name!);
        }
        await _storageService.saveBool('is_authenticated', true);

        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response.data['message'] ?? 'Registration failed');
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 
          e.message ?? 
          'Registration failed. Please try again.';
      _setError(errorMessage);
      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _setLoading(true);

      try {
        await _apiService.post('/api/auth/logout');
      } catch (e) {
        // Continue with logout even if API call fails
        print('Logout API call failed: $e');
      }

      await _storageService.removeToken();
      await _storageService.remove('user_id');
      await _storageService.remove('user_email');
      await _storageService.remove('user_name');
      await _storageService.saveBool('is_authenticated', false);

      _user = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Check if user is logged in and restore session
  Future<void> checkAuthStatus() async {
    try {
      await _storageService.ensureInitialized();
      final token = _storageService.getToken();
      final isAuthenticated =
          _storageService.getBool('is_authenticated') ?? false;

      if (token != null && isAuthenticated) {
        try {
          // Verify token with backend
          final response = await _apiService.get('/api/auth/me');
          if (response.data['success'] == true) {
            final userData = response.data['user'];
            _user = UserModel(
              id: userData['id'],
              email: userData['email'],
              name: userData['name'],
              avatar: userData['avatar'],
            );
            notifyListeners();
          } else {
            // Token invalid, clear storage
            await _storageService.removeToken();
            await _storageService.saveBool('is_authenticated', false);
            _user = null;
            notifyListeners();
          }
        } catch (e) {
          // Token invalid or network error, restore from storage
          final userId = _storageService.getString('user_id');
          final userEmail = _storageService.getString('user_email');
          final userName = _storageService.getString('user_name');

          if (userId != null && userEmail != null) {
            _user = UserModel(
              id: userId,
              email: userEmail,
              name: userName,
            );
            notifyListeners();
          } else {
            _user = null;
            notifyListeners();
          }
        }
      } else {
        _user = null;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
      _user = null;
      notifyListeners();
    }
  }
}
