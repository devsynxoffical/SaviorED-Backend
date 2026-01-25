import 'package:flutter/foundation.dart';
import '../../../services/api_service.dart';
import '../models/castle_grounds_model.dart';
import '../models/placed_item_model.dart';

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

  /// Save castle layout
  Future<bool> saveLayout(List<PlacedItemModel> items) async {
    try {
      setLoading(true);
      setError(null);

      final response = await _apiService.put(
        '/api/castles/update-layout',
        data: {'placed_items': items.map((e) => e.toJson()).toList()},
      );

      if (response.data['success'] == true) {
        _castle = CastleGroundsModel.fromJson(response.data);
        setLoading(false);
        notifyListeners();
        return true;
      } else {
        setError(response.data['message'] ?? 'Failed to save layout');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  /// Spend resources to build an item
  Future<bool> spendResources({
    required int coins,
    required int wood,
    required int stone,
    String? itemId, // Added to track which item is bought
  }) async {
    try {
      // Optimistic check
      if ((_castle?.coins ?? 0) < coins ||
          (_castle?.wood ?? 0) < wood ||
          (_castle?.stones ?? 0) < stone) {
        setError('Not enough resources!');
        return false;
      }

      setLoading(true);
      setError(null);

      // Optimistically update local state immediately for snappy UI
      _castle = _castle?.copyWith(
        coins: (_castle?.coins ?? 0) - coins,
        wood: (_castle?.wood ?? 0) - wood,
        stones: (_castle?.stones ?? 0) - stone,
      );
      notifyListeners();

      final response = await _apiService.post(
        '/api/castles/spend-resources',
        data: {
          'coins': coins,
          'wood': wood,
          'stone': stone,
          'itemId': itemId, // Pass the item being purchased
        },
      );

      if (response.data['success'] == true) {
        // Sync with server state to be sure
        _castle = CastleGroundsModel.fromJson(response.data['castle']);
        setLoading(false);
        notifyListeners();
        return true;
      } else {
        // Revert on failure
        setError(response.data['message'] ?? 'Failed to spend resources');
        await getMyCastle(); // Reload to revert state
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError(e.toString());
      await getMyCastle(); // Reload to revert state
      setLoading(false);
      return false;
    }
  }

  /// Update castle state directly from data (e.g., after layout sync)
  void updateFromData(Map<String, dynamic> data) {
    try {
      _castle = CastleGroundsModel.fromJson(data);
      notifyListeners();
    } catch (e) {
      print('Failed to update castle from data: $e');
    }
  }
}
