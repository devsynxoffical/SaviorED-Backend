import 'package:flutter/foundation.dart';
import '../models/placed_item_model.dart';
import '../models/level_model.dart';
import '../models/level_requirements_model.dart';
import '../models/level_progress_model.dart';
import '../config/level_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../services/storage_service.dart';
import '../../../services/api_service.dart';

class BaseBuildingViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  String? _errorMessage;
  List<PlacedItemModel> _placedItems = [];

  // Level System State
  int _currentLevel = 1;
  LevelModel _currentLevelConfig = LevelConfig.getLevel(1);
  LevelProgress? _levelProgress;

  // Resources
  final Map<String, int> _resources = {
    'coins': 1250,
    'wood': 750,
    'stone': 300,
  };
  Map<String, int> get resources => _resources;

  // View State
  bool _isPlacementMode = false;
  String? _selectedItemTemplateId;
  bool _isFlippedGlobal = false;
  String? _selectedDetailTemplateId;
  String? _selectedPlacedItemId;

  // Drag Preview State
  int? _previewGridX;
  int? _previewGridY;
  String? _previewTemplateId;
  bool _isDragging = false;
  bool _isPreviewValid = true;
  String? _dragItemId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PlacedItemModel> get placedItems => _placedItems;

  int get currentLevel => _currentLevel;
  LevelModel get currentLevelConfig => _currentLevelConfig;
  LevelProgress? get levelProgress => _levelProgress;

  bool get isPlacementMode => _isPlacementMode;
  String? get selectedItemTemplateId => _selectedItemTemplateId;
  bool get isFlippedGlobal => _isFlippedGlobal;
  String? get selectedDetailTemplateId => _selectedDetailTemplateId;
  String? get selectedPlacedItemId => _selectedPlacedItemId;

  PlacedItemModel? get selectedPlacedItem {
    if (_selectedPlacedItemId == null) return null;
    for (var item in _placedItems) {
      if (item.id == _selectedPlacedItemId) return item;
    }
    return null;
  }

  int? get previewGridX => _previewGridX;
  int? get previewGridY => _previewGridY;
  String? get previewTemplateId => _previewTemplateId;
  bool get isDragging => _isDragging;
  bool get isPreviewValid => _isPreviewValid;
  String? get dragItemId => _dragItemId;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void startPlacementMode(String templateId) {
    _isPlacementMode = true;
    _selectedItemTemplateId = templateId;
    notifyListeners();
  }

  void cancelPlacementMode() {
    _isPlacementMode = false;
    _selectedItemTemplateId = null;
    notifyListeners();
  }

  void updateDragPreview(
    int? x,
    int? y,
    String? templateId, {
    String? excludeId,
  }) {
    _previewGridX = x;
    _previewGridY = y;
    _previewTemplateId = templateId;
    _dragItemId = excludeId;
    _isDragging = (x != null && y != null);

    if (_isDragging && x != null && y != null && templateId != null) {
      final size = getItemSize(templateId);
      _isPreviewValid = !isAreaOccupied(x, y, size, excludeId: excludeId);
    } else {
      _isPreviewValid = true;
    }
    notifyListeners();
  }

  void toggleGlobalFlip() {
    _isFlippedGlobal = !_isFlippedGlobal;
    notifyListeners();
  }

  void selectDetailTemplate(String? templateId) {
    _selectedDetailTemplateId = templateId;
    notifyListeners();
  }

  void selectPlacedItem(String? itemId) {
    _selectedPlacedItemId = itemId;
    if (itemId != null) {
      // Also set the detail template so the UI knows which building to show
      final item = _placedItems.firstWhere((i) => i.id == itemId);
      _selectedDetailTemplateId = item.itemId;
    }
    notifyListeners();
  }

  bool _isVisitorMode = false;
  String? _visitorName;

  bool get isVisitorMode => _isVisitorMode;
  String? get visitorName => _visitorName;

  // User Session Tracking
  String? _currentUserId;

  /// Load base layout from locally saved data or backend
  Future<void> loadBase() async {
    if (_isVisitorMode) return; // Don't load local base if in visitor mode

    try {
      setLoading(true);
      setError(null);

      final userId = _storageService.getString('user_id') ?? 'guest';

      // CRITICAL: Clear state if user changed (e.g. Logout -> Login new user)
      if (_currentUserId != userId) {
        print(
          '🔄 User changed from $_currentUserId to $userId. Resetting base state.',
        );
        _placedItems = [];
        _currentLevel = 1;
        _currentLevelConfig = LevelConfig.getLevel(1);
        _levelProgress = null;
        _currentUserId = userId; // Update tracking ID
      }

      final baseKey = 'saved_base_${userId}_v1';
      final levelKey = 'current_level_$userId';

      // 1. Try to fetch from backend first (Source of Truth)
      try {
        final response = await _apiService.get('/api/castles/my-castle');
        if (response.data['success'] == true) {
          final castleData = response.data['castle'] ?? response.data;

          // Update Resources from Castle Data
          _resources['coins'] = castleData['coins'] ?? 0;
          _resources['wood'] = castleData['wood'] ?? 0;
          _resources['stone'] =
              castleData['stones'] ?? 0; // Backend uses 'stones'

          final List<dynamic> layoutData =
              castleData['layout'] ??
              castleData['placed_items'] ??
              castleData['placedItems'] ??
              [];

          // Always update items, even if empty (clears old user data if backend is empty)
          _placedItems = layoutData
              .map((item) => PlacedItemModel.fromJson(item))
              .toList();

          _currentLevel = castleData['level'] ?? 1;
          _currentLevelConfig = LevelConfig.getLevel(_currentLevel);

          // Update local storage with fresh data
          final String encoded = jsonEncode(
            _placedItems.map((item) => item.toJson()).toList(),
          );
          await _storageService.saveString(baseKey, encoded);
          await _storageService.saveInt(levelKey, _currentLevel);

          _updateLevelProgress();
          setLoading(false);
          notifyListeners();
          return; // Successfully loaded from backend
        }
      } catch (e) {
        print('🌐 Backend fetch failed, falling back to local: $e');
      }

      // 2. Fallback to local storage (user-specific)
      final String? baseData = _storageService.getString(baseKey);

      if (baseData != null) {
        final List<dynamic> decoded = jsonDecode(baseData);
        _placedItems = decoded
            .map((item) => PlacedItemModel.fromJson(item))
            .toList();

        _currentLevel = _storageService.getInt(levelKey) ?? 1;
        _currentLevelConfig = LevelConfig.getLevel(_currentLevel);
      } else {
        // Fresh start for this specific user
        _placedItems = [];
        _currentLevel = 1;
        _currentLevelConfig = LevelConfig.getLevel(1);
      }

      _updateLevelProgress();
      setLoading(false);
      notifyListeners();
    } catch (e) {
      print('⚠️ Failed to load base: $e');
      // Only clear if we are in a broken state for the CURRENT user
      // But don't clear if just a network error on existing data
      setLoading(false);
      notifyListeners();
    }
  }

  /// Fetch another user's base for visiting
  Future<void> fetchVisitorBase(String userId, String userName) async {
    try {
      setLoading(true);
      setError(null);
      _isVisitorMode = true;
      _visitorName = userName;

      final response = await _apiService.get('/api/castles/$userId');

      if (response.data['success'] == true) {
        final castleData = response.data['castle'];
        final List<dynamic> layoutData = castleData['layout'] ?? [];

        _placedItems = layoutData
            .map((item) => PlacedItemModel.fromJson(item))
            .toList();

        _currentLevel = castleData['level'] ?? 1;
        _currentLevelConfig = LevelConfig.getLevel(_currentLevel);

        _updateLevelProgress();
        setLoading(false);
        notifyListeners();
      } else {
        setError(response.data['message'] ?? 'Failed to load visitor base');
        setLoading(false);
      }
    } catch (e) {
      setError('Error visiting base: $e');
      setLoading(false);
    }
  }

  void clearVisitorMode() {
    _isVisitorMode = false;
    _visitorName = null;
    loadBase(); // Reload current user's base
  }

  /// Clear all in-memory state (useful on logout)
  void clearState() {
    _placedItems = [];
    _currentLevel = 1;
    _currentLevelConfig = LevelConfig.getLevel(1);
    _levelProgress = null;
    _isPlacementMode = false;
    _selectedPlacedItemId = null;
    _selectedDetailTemplateId = null;
    _selectedItemTemplateId = null;
    _isVisitorMode = false;
    _visitorName = null;
    notifyListeners();
  }

  /// Save base layout to local storage and sync to backend
  Future<void> saveBase() async {
    if (_isVisitorMode) return; // Disable saving in visitor mode
    try {
      final userId = _storageService.getString('user_id') ?? 'guest';
      final baseKey = 'saved_base_${userId}_v1';
      final levelKey = 'current_level_$userId';

      final String encoded = jsonEncode(
        _placedItems.map((item) => item.toJson()).toList(),
      );
      await _storageService.saveString(baseKey, encoded);
      await _storageService.saveInt(levelKey, _currentLevel);

      // Sync to live database for Leaderboard view
      await _syncBaseToBackend(encoded);
    } catch (e) {
      print('⚠️ Failed to save base: $e');
    }
  }

  Function(Map<String, dynamic>)? onCastleDataUpdated;

  /// Sync base layout to backend
  Future<void> _syncBaseToBackend(String baseData) async {
    try {
      // Decode the string back to JSON object to send proper structure
      final layoutData = jsonDecode(baseData);

      // Calculate completion based on items
      double progress = 0.0;
      if (_levelProgress != null) {
        progress =
            _levelProgress!.calculateCompletionPercentage(
              _currentLevelConfig.requirements,
            ) *
            100;
        // Clamp 0-100
        if (progress > 100) progress = 100;
      }

      final response = await _apiService.put(
        '/api/castles/layout',
        data: {
          'layout': layoutData,
          'level': _currentLevel,
          'progressPercentage': progress,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      if (response.data['success'] == true) {
        print('✅ Base synced to backend successfully.');

        // Notify listener (CastleGroundsViewModel) to update inventory/stock
        if (response.data['castle'] != null && onCastleDataUpdated != null) {
          onCastleDataUpdated!(response.data['castle']);
        }
      } else {
        print('⚠️ Backend sync failed: ${response.data['message']}');
      }
    } catch (e) {
      print('⚠️ Failed to sync base to backend: $e');
    }
  }

  /// Get grid size for a specific item template
  int getItemSize(String templateId) {
    if (templateId.contains('gate')) return 7;
    if (templateId.contains('wall')) return 2;
    if (templateId.contains('tower') || templateId.contains('house')) return 5;
    return 2; // Default
  }

  /// Check if an area is occupied by any item
  bool isAreaOccupied(int x, int y, int size, {String? excludeId}) {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (_isCellOccupied(x + i, y + j, excludeId: excludeId)) return true;
      }
    }
    return false;
  }

  bool _isCellOccupied(int x, int y, {String? excludeId}) {
    return _placedItems.any((item) {
      final size = getItemSize(item.itemId);
      bool horizontalOverlap = x >= item.gridX && x < item.gridX + size;
      bool verticalOverlap = y >= item.gridY && y < item.gridY + size;
      return horizontalOverlap && verticalOverlap && item.id != excludeId;
    });
  }

  /// Place an item on the base
  Future<void> placeItem({
    required String itemType,
    required String itemId,
    required int gridX,
    required int gridY,
    double rotation = 0,
  }) async {
    if (_isVisitorMode) return; // Disable editing in visitor mode
    try {
      final size = getItemSize(itemId);
      if (isAreaOccupied(gridX, gridY, size)) {
        print(
          '⚠️ Position ($gridX, $gridY) or its $size x $size neighbors are occupied',
        );
        return;
      }

      final newItem = PlacedItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        itemType: itemType,
        itemId: itemId,
        gridX: gridX,
        gridY: gridY,
        rotation: rotation,
        isFlipped: _isFlippedGlobal,
        placedAt: DateTime.now(),
      );

      _placedItems = [..._placedItems, newItem];
      _updateLevelProgress();

      // AUTO-SAVE
      await saveBase();

      notifyListeners();
    } catch (e) {
      setError('Failed to place item: $e');
    }
  }

  /// Remove an item from the base
  Future<void> removeItem(String itemId) async {
    if (_isVisitorMode) return; // Disable editing in visitor mode
    try {
      _placedItems = _placedItems.where((item) => item.id != itemId).toList();
      _updateLevelProgress();

      // AUTO-SAVE
      await saveBase();

      notifyListeners();
    } catch (e) {
      setError('Failed to remove item: $e');
    }
  }

  /// Update item position or rotation
  Future<void> updateItem({
    required String itemId,
    int? gridX,
    int? gridY,
    double? rotation,
    bool? isFlipped,
  }) async {
    if (_isVisitorMode) return; // Disable editing in visitor mode
    try {
      _placedItems = _placedItems.map((item) {
        if (item.id == itemId) {
          return item.copyWith(
            gridX: gridX ?? item.gridX,
            gridY: gridY ?? item.gridY,
            rotation: rotation ?? item.rotation,
            isFlipped: isFlipped ?? item.isFlipped,
          );
        }
        return item;
      }).toList();

      // AUTO-SAVE
      await saveBase();

      notifyListeners();
    } catch (e) {
      setError('Failed to update item: $e');
    }
  }

  /// Upgrade an item to a new template ID
  Future<void> upgradeItem(String itemId, String newTemplateId) async {
    if (_isVisitorMode) return; // Disable editing in visitor mode
    try {
      _placedItems = _placedItems.map((item) {
        if (item.id == itemId) {
          // Keep position, rotation, etc., but change the template ID (e.g., wall_basic -> wall_medium)
          return item.copyWith(itemId: newTemplateId);
        }
        return item;
      }).toList();

      _updateLevelProgress();
      // AUTO-SAVE
      await saveBase();
      notifyListeners();

      // Update selection details if this was the selected item
      if (_selectedPlacedItemId == itemId) {
        _selectedDetailTemplateId = newTemplateId;
      }
    } catch (e) {
      setError('Failed to upgrade item: $e');
    }
  }

  void _updateLevelProgress() {
    final requirements = _currentLevelConfig.requirements;
    Map<String, int> currentCounts = {};
    for (var item in _placedItems) {
      currentCounts[item.itemId] = (currentCounts[item.itemId] ?? 0) + 1;
    }

    _levelProgress = LevelProgress(
      level: _currentLevel,
      unlockedItems: {},
      placedItems: currentCounts,
      isCompleted: _checkCompletion(requirements, currentCounts),
    );
  }

  bool _checkCompletion(
    LevelRequirements reqs,
    Map<String, int> currentCounts,
  ) {
    for (var req in reqs.requiredItems) {
      final current = currentCounts[req.itemTemplateId] ?? 0;
      if (current < req.quantity) return false;
    }
    return true;
  }

  Future<void> completeLevel() async {
    if (_levelProgress?.isCompleted ?? false) {
      if (_currentLevel < LevelConfig.levels.length) {
        _currentLevel++;
        _currentLevelConfig = LevelConfig.getLevel(_currentLevel);
        _updateLevelProgress();
        await saveBase();
        notifyListeners();
      }
    }
  }
}
