import 'package:flutter/foundation.dart';
import '../../../services/api_service.dart';
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
      }
    } catch (e) {
      setError(e.toString());
      setLoading(false);
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
}
