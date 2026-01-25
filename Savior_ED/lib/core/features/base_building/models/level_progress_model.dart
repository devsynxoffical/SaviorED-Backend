import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'level_requirements_model.dart';

class LevelProgress extends Equatable {
  final int level;
  final Map<String, int> unlockedItems; // itemId -> count
  final Map<String, int> placedItems; // itemId -> count
  final bool isCompleted;

  const LevelProgress({
    required this.level,
    required this.unlockedItems,
    required this.placedItems,
    this.isCompleted = false,
  });

  LevelProgress copyWith({
    int? level,
    Map<String, int>? unlockedItems,
    Map<String, int>? placedItems,
    bool? isCompleted,
  }) {
    return LevelProgress(
      level: level ?? this.level,
      unlockedItems: unlockedItems ?? this.unlockedItems,
      placedItems: placedItems ?? this.placedItems,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  double calculateCompletionPercentage(LevelRequirements requirements) {
    if (requirements.requiredItems.isEmpty) return 1.0;

    int totalNeeded = 0;
    int totalValidPlaced = 0;

    for (var req in requirements.requiredItems) {
      totalNeeded += req.quantity;
      final actualPlaced = placedItems[req.itemTemplateId] ?? 0;
      // Only count items required for this level, and only up to the required amount
      totalValidPlaced += math.min(actualPlaced, req.quantity);
    }

    if (totalNeeded == 0) return 1.0;
    return (totalValidPlaced / totalNeeded).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [level, unlockedItems, placedItems, isCompleted];
}

// Added math import at top level or just use min from dart:math if available, 
// usually easier to just use manual check if min isn't imported.
// I'll add the import.

