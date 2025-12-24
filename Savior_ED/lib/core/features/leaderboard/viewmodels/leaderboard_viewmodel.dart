import 'package:flutter/foundation.dart';
import '../../../services/api_service.dart';
import '../models/leaderboard_entry_model.dart';

class LeaderboardViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<LeaderboardEntryModel> _globalEntries = [];
  List<LeaderboardEntryModel> _schoolEntries = [];
  String _currentType = 'global';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<LeaderboardEntryModel> get globalEntries => _globalEntries;
  List<LeaderboardEntryModel> get schoolEntries => _schoolEntries;
  String get currentType => _currentType;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Get global leaderboard
  Future<void> getGlobalLeaderboard({int page = 1, int limit = 20}) async {
    try {
      setLoading(true);
      setError(null);
      _currentType = 'global';

      final response = await _apiService.get(
        '/api/leaderboard/global',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.data['success'] == true) {
        final entriesList = response.data['entries'] as List;
        _globalEntries = entriesList
            .map((json) => LeaderboardEntryModel.fromJson(json))
            .toList();
        setLoading(false);
        notifyListeners();
      } else {
        setError(response.data['message'] ?? 'Failed to load leaderboard');
        setLoading(false);
      }
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

  /// Get school leaderboard
  Future<void> getSchoolLeaderboard({int page = 1, int limit = 20}) async {
    try {
      setLoading(true);
      setError(null);
      _currentType = 'school';

      final response = await _apiService.get(
        '/api/leaderboard/school',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.data['success'] == true) {
        final entriesList = response.data['entries'] as List;
        _schoolEntries = entriesList
            .map((json) => LeaderboardEntryModel.fromJson(json))
            .toList();
        setLoading(false);
        notifyListeners();
      } else {
        setError(response.data['message'] ?? 'Failed to load leaderboard');
        setLoading(false);
      }
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }
}

