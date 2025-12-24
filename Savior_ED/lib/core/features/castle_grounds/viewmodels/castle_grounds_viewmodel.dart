import 'package:flutter/foundation.dart';
import '../../../services/api_service.dart';
import '../models/castle_grounds_model.dart';

class CastleGroundsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _errorMessage;
  CastleGroundsModel? _castle;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CastleGroundsModel? get castle => _castle;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Get user's castle
  Future<void> getMyCastle() async {
    try {
      setLoading(true);
      setError(null);

      final response = await _apiService.get('/api/castles/my-castle');

      if (response.data['success'] == true) {
        _castle = CastleGroundsModel.fromJson(response.data);
        setLoading(false);
        notifyListeners();
      } else {
        setError(response.data['message'] ?? 'Failed to load castle');
        setLoading(false);
      }
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

  /// Level up castle
  Future<bool> levelUp() async {
    try {
      setLoading(true);
      setError(null);

      final response = await _apiService.put('/api/castles/level-up');

      if (response.data['success'] == true) {
        _castle = CastleGroundsModel.fromJson(response.data);
        setLoading(false);
        notifyListeners();
        return true;
      } else {
        setError(response.data['message'] ?? 'Failed to level up');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  /// Get castle by user ID
  Future<CastleGroundsModel?> getCastleByUserId(String userId) async {
    try {
      setLoading(true);
      setError(null);

      final response = await _apiService.get('/api/castles/$userId');

      if (response.data['success'] == true) {
        final castle = CastleGroundsModel.fromJson(response.data);
        setLoading(false);
        return castle;
      } else {
        setError(response.data['message'] ?? 'Castle not found');
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
