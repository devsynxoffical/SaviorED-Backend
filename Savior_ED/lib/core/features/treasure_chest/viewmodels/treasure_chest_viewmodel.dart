import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../services/api_service.dart';
import '../../../services/analytics_service.dart';
import '../../../consts/app_consts.dart';
import '../models/treasure_chest_model.dart';

class TreasureChestViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  TreasureChestModel? _treasureChest;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TreasureChestModel? get treasureChest => _treasureChest;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Get user's treasure chest
  Future<void> getMyChest() async {
    try {
      setLoading(true);
      setError(null);

      final response = await _apiService.get('/api/treasure-chests/my-chest');

      if (response.data['success'] == true) {
        _treasureChest = TreasureChestModel.fromJson(response.data);
        setLoading(false);
        notifyListeners();
      } else {
        setError(response.data['message'] ?? 'Failed to load treasure chest');
        setLoading(false);
        notifyListeners();
      }
    } on DioException catch (e) {
      print('❌ Treasure Chest DioException: ${e.type}');
      print('❌ Error message: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      print('❌ Status code: ${e.response?.statusCode}');

      String errorMsg = 'Failed to load treasure chest';
      if (e.response != null) {
        errorMsg =
            e.response!.data['message'] ??
            'Server error: ${e.response!.statusCode}';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg =
            'Cannot connect to server. Please check if the backend is running.';
      } else {
        errorMsg = e.message ?? 'Unknown error occurred';
      }

      setError(errorMsg);
      setLoading(false);
      notifyListeners();
    } catch (e) {
      print('❌ Error loading treasure chest: $e');
      setError(e.toString());
      setLoading(false);
      notifyListeners();
    }
  }

  /// Update treasure chest progress
  Future<bool> updateProgress(double progressPercentage) async {
    try {
      setLoading(true);
      setError(null);

      final response = await _apiService.put(
        '/api/treasure-chests/update-progress',
        data: {'progressPercentage': progressPercentage},
      );

      if (response.data['success'] == true) {
        _treasureChest = TreasureChestModel.fromJson(response.data);
        setLoading(false);
        notifyListeners();
        return true;
      } else {
        setError(response.data['message'] ?? 'Failed to update progress');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  /// Claim treasure chest rewards
  Future<bool> claimRewards() async {
    try {
      setLoading(true);
      setError(null);

      final response = await _apiService.put('/api/treasure-chests/claim');

      if (response.data['success'] == true) {
        _treasureChest = TreasureChestModel.fromJson(response.data);

        // Analytics: Log treasure chest opened
        await AnalyticsService.logTreasureChestOpened();

        setLoading(false);
        notifyListeners();
        return true;
      } else {
        setError(response.data['message'] ?? 'Failed to claim rewards');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  /// Refresh treasure chest data
  Future<void> refresh() async {
    await getMyChest();
  }

  /// Add focus minutes to progress
  Future<bool> addFocusMinutes(double minutes) async {
    try {
      // 1. Ensure we have the latest chest data
      if (_treasureChest == null) {
        await getMyChest();
      }

      if (_treasureChest == null) return false;

      // 2. Calculate added progress (AppConsts.chestUnlockMinutes = 100%)
      final addedProgress =
          (minutes / AppConsts.chestUnlockMinutes.toDouble()) * 100.0;

      // 3. Calculate new total progress
      double newProgress = _treasureChest!.progressPercentage + addedProgress;

      // If already unlocked and not claimed, keep at 100%
      if (_treasureChest!.isUnlocked && !_treasureChest!.isClaimed) {
        newProgress = 100.0;
      }

      // 4. Update progress on backend
      return await updateProgress(newProgress);
    } catch (e) {
      print('❌ Error adding focus minutes: $e');
      return false;
    }
  }
}
