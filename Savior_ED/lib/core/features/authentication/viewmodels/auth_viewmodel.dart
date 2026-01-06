import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../services/storage_service.dart';
import '../../../services/api_service.dart';
import '../../../services/analytics_service.dart';
import '../../../consts/app_consts.dart';
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
        if (_user!.avatar != null) {
          await _storageService.saveString('user_avatar', _user!.avatar!);
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
      String errorMessage;
      if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Connection refused. Please check your internet connection and ensure the server is running.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? 
            e.message ?? 
            'Login failed. Please check your credentials.';
      } else {
        errorMessage = e.message ?? 'Login failed. Please check your credentials.';
      }
      _setError(errorMessage);
      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
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

      print('📝 Starting registration for: $email');
      print('🔗 Backend URL: ${AppConsts.baseUrl}');
      
      final response = await _apiService.post('/api/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
      });
      
      print('✅ Registration response received: ${response.statusCode}');

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
        if (_user!.avatar != null) {
          await _storageService.saveString('user_avatar', _user!.avatar!);
        }
        await _storageService.saveBool('is_authenticated', true);

        // Analytics: Log signup and set user ID
        await AnalyticsService.logSignUp(signUpMethod: 'email');
        await AnalyticsService.setUserId(_user!.id);

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
      print('❌ DioException during registration:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      print('   Status Code: ${e.response?.statusCode}');
      print('   Request URL: ${e.requestOptions.uri}');
      
      String errorMessage;
      if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Cannot connect to server. Please check:\n'
            '1. Your internet connection\n'
            '2. Backend is running at: ${AppConsts.baseUrl}\n'
            '3. Try again in a few moments';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Connection timeout. The server took too long to respond.\n'
            'This might be due to:\n'
            '1. Slow internet connection\n'
            '2. Server is starting up (Railway cold start)\n'
            '3. Server is overloaded\n'
            'Please try again.';
      } else if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? 
            e.message ?? 
            'Registration failed. Please try again.';
      } else {
        errorMessage = 'Network error: ${e.message ?? "Unknown error"}\n'
            'Please check your internet connection and try again.';
      }
      _setError(errorMessage);
      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      print('❌ Unexpected error during registration: $e');
      print('Stack trace: $stackTrace');
      _setError('An unexpected error occurred: ${e.toString()}');
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

  /// Google OAuth login
  Future<bool> loginWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      print('🔵 Starting Google Sign-In...');

      // Try native Google Sign-In first (better UX)
      try {
        // Initialize GoogleSignIn for Android
        // To get ID token, we need serverClientId (Web OAuth client ID)
        // For now, we'll try without it and handle null ID token
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
          // Note: serverClientId is needed to get ID token
          // If you create a Web OAuth client, add it here:
          // serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
        );

        // Sign out first to ensure fresh sign-in
        await googleSignIn.signOut();

        // Sign in with Google
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          // User cancelled the sign-in
          print('⚠️ User cancelled Google Sign-In');
          _setLoading(false);
          notifyListeners();
          return false;
        }

        print('✅ Google Sign-In successful: ${googleUser.email}');

        // Get authentication details
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        print('📤 Authenticating with backend using Google credentials...');
        print('   Email: ${googleUser.email}');
        print('   ID Token: ${googleAuth.idToken != null ? "Present" : "Null"}');
        print('   Access Token: ${googleAuth.accessToken != null ? "Present" : "Null"}');

        // Send Google credentials to backend
        // If ID token is null, backend can use access token or email for verification
        final response = await _apiService.post('/api/auth/google/mobile', data: {
          'idToken': googleAuth.idToken, // May be null - backend should handle this
          'accessToken': googleAuth.accessToken,
          'email': googleUser.email,
          'name': googleUser.displayName ?? '',
          'photo': googleUser.photoUrl,
        });

        if (response.data['success'] == true) {
          final userData = response.data['user'];
          final token = response.data['token'];

          _user = UserModel(
            id: userData['id'],
            email: userData['email'],
            name: userData['name'],
            avatar: userData['avatar'] ?? googleUser.photoUrl,
          );

          await _storageService.saveToken(token);
          await _storageService.saveString('user_id', _user!.id);
          await _storageService.saveString('user_email', _user!.email);
          if (_user!.name != null) {
            await _storageService.saveString('user_name', _user!.name!);
          }
          if (_user!.avatar != null) {
            await _storageService.saveString('user_avatar', _user!.avatar!);
          }
          await _storageService.saveBool('is_authenticated', true);

          // Analytics: Log login and set user ID
          await AnalyticsService.logLogin(loginMethod: 'google');
          await AnalyticsService.setUserId(_user!.id);

          _setLoading(false);
          notifyListeners();
          print('✅ Google login successful!');
          return true;
        } else {
          throw Exception(response.data['message'] ?? 'Authentication failed');
        }
      } catch (e) {
        print('❌ Native Google Sign-In failed: $e');
        
        // Don't fall back to web OAuth - it requires redirect URI configuration
        // Instead, show a helpful error message
        String errorMessage = 'Google Sign-In failed. ';
        
        if (e.toString().contains('platform_exception') || 
            e.toString().contains('sign_in_failed') ||
            e.toString().contains('DEVELOPER_ERROR')) {
          errorMessage += '\n\nThis usually means:\n'
              '1. SHA-1 fingerprint not configured in Google Cloud Console\n'
              '2. Package name mismatch\n'
              '3. OAuth client not properly set up\n\n'
              'Please check GOOGLE_SIGNIN_SETUP.md for setup instructions.';
        } else if (e.toString().contains('network')) {
          errorMessage += '\n\nNetwork error. Please check your internet connection.';
        } else {
          errorMessage += '\n\nError: ${e.toString()}';
        }
        
        _setError(errorMessage);
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      _setError('Google sign-in failed: ${e.toString()}\n\nPlease try using email/password instead.');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Check if user is logged in and restore session
  /// This method prioritizes local storage for immediate restoration
  /// and validates token in the background without blocking
  Future<void> checkAuthStatus() async {
    try {
      await _storageService.ensureInitialized();
      final token = _storageService.getToken();
      final isAuthenticated =
          _storageService.getBool('is_authenticated') ?? false;

      // First, restore user from local storage immediately (offline support)
      if (token != null && isAuthenticated) {
        final userId = _storageService.getString('user_id');
        final userEmail = _storageService.getString('user_email');
        final userName = _storageService.getString('user_name');

        if (userId != null && userEmail != null) {
          // Restore user from storage immediately
          _user = UserModel(
            id: userId,
            email: userEmail,
            name: userName,
            avatar: _storageService.getString('user_avatar'),
          );
          notifyListeners();

          // Validate token in background (non-blocking)
          // If validation fails with 401, then clear token
          _validateTokenInBackground();
        } else {
          // No user data in storage, clear everything
          await _storageService.removeToken();
          await _storageService.saveBool('is_authenticated', false);
          _user = null;
          notifyListeners();
        }
      } else {
        // No token or not authenticated, clear user
        _user = null;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error checking auth status: $e');
      // On error, try to restore from storage as fallback
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
  }

  /// Validate token in background without blocking the UI
  /// Only clears token if backend explicitly says it's invalid (401)
  Future<void> _validateTokenInBackground() async {
    try {
      final response = await _apiService.get('/api/auth/me');
      if (response.data['success'] == true) {
        final userData = response.data['user'];
        // Update user with latest data from backend
        _user = UserModel(
          id: userData['id'],
          email: userData['email'],
          name: userData['name'],
          avatar: userData['avatar'],
        );
        // Update stored user data
        await _storageService.saveString('user_id', _user!.id);
        await _storageService.saveString('user_email', _user!.email);
        if (_user!.name != null) {
          await _storageService.saveString('user_name', _user!.name!);
        }
        if (_user!.avatar != null) {
          await _storageService.saveString('user_avatar', _user!.avatar!);
        }
        notifyListeners();
      }
    } on DioException catch (e) {
      // Only clear token if we get 401 Unauthorized (token is invalid)
      // Don't clear on network errors or other errors
      if (e.response?.statusCode == 401) {
        print('⚠️ Token invalid (401), logging out...');
        await _storageService.removeToken();
        await _storageService.saveBool('is_authenticated', false);
        _user = null;
        notifyListeners();
      } else {
        // Network error or other error - keep user logged in with local data
        print('⚠️ Token validation failed (non-401), keeping user logged in: ${e.message}');
      }
    } catch (e) {
      // Other errors - keep user logged in
      print('⚠️ Token validation error, keeping user logged in: $e');
    }
  }
}
