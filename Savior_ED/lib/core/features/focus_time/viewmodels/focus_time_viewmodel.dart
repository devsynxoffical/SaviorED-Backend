import 'package:flutter/foundation.dart';
import '../../../services/api_service.dart';
import '../models/focus_time_model.dart';

class FocusTimeViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _errorMessage;
  FocusTimeModel? _currentSession;
  List<FocusTimeModel> _sessions = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  FocusTimeModel? get currentSession => _currentSession;
  List<FocusTimeModel> get sessions => _sessions;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Create a new focus session
  Future<FocusTimeModel?> createSession(int durationMinutes) async {
    try {
      setLoading(true);
      setError(null);

      final response = await _apiService.post('/api/focus-sessions', data: {
        'durationMinutes': durationMinutes,
      });

      if (response.data['success'] == true) {
        final sessionData = response.data['session'];
        _currentSession = FocusTimeModel.fromJson(sessionData);
        setLoading(false);
        notifyListeners();
        return _currentSession;
      } else {
        setError(response.data['message'] ?? 'Failed to create session');
        setLoading(false);
        return null;
      }
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return null;
    }
  }

  /// Get user's focus sessions
  Future<void> getSessions({int page = 1, int limit = 20}) async {
    try {
      setLoading(true);
      setError(null);

      final response = await _apiService.get(
        '/api/focus-sessions',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.data['success'] == true) {
        final sessionsList = response.data['sessions'] as List;
        _sessions = sessionsList
            .map((json) => FocusTimeModel.fromJson(json))
            .toList();
        setLoading(false);
        notifyListeners();
      } else {
        setError(response.data['message'] ?? 'Failed to load sessions');
        setLoading(false);
      }
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

  /// Get session by ID
  Future<FocusTimeModel?> getSessionById(String sessionId) async {
    try {
      setLoading(true);
      setError(null);

      final response = await _apiService.get('/api/focus-sessions/$sessionId');

      if (response.data['success'] == true) {
        final session = FocusTimeModel.fromJson(response.data['session']);
        setLoading(false);
        return session;
      } else {
        setError(response.data['message'] ?? 'Session not found');
        setLoading(false);
        return null;
      }
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return null;
    }
  }

  /// Update focus session (pause, resume, update time)
  Future<bool> updateSession({
    required String sessionId,
    int? totalSeconds,
    bool? isPaused,
    bool? isRunning,
    bool? focusLost,
  }) async {
    try {
      setLoading(true);
      setError(null);

      final data = <String, dynamic>{};
      if (totalSeconds != null) data['totalSeconds'] = totalSeconds;
      if (isPaused != null) data['isPaused'] = isPaused;
      if (isRunning != null) data['isRunning'] = isRunning;
      if (focusLost != null) data['focusLost'] = focusLost;

      final response = await _apiService.put(
        '/api/focus-sessions/$sessionId/update',
        data: data,
      );

      if (response.data['success'] == true) {
        _currentSession = FocusTimeModel.fromJson(response.data['session']);
        setLoading(false);
        notifyListeners();
        return true;
      } else {
        setError(response.data['message'] ?? 'Failed to update session');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  /// Complete focus session
  Future<Map<String, dynamic>?> completeSession({
    required String sessionId,
    required int totalSeconds,
  }) async {
    try {
      setLoading(true);
      setError(null);

      final response = await _apiService.put(
        '/api/focus-sessions/$sessionId/complete',
        data: {'totalSeconds': totalSeconds},
      );

      if (response.data['success'] == true) {
        _currentSession = FocusTimeModel.fromJson(response.data['session']);
        final rewards = response.data['rewards'];
        setLoading(false);
        notifyListeners();
        return rewards;
      } else {
        setError(response.data['message'] ?? 'Failed to complete session');
        setLoading(false);
        return null;
      }
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return null;
    }
  }
}
