import 'package:equatable/equatable.dart';

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

  double calculateCompletionPercentage(int totalRequired) {
    // Simplified: just based on items placed vs total items required
    // In a real scenario you'd match against specific requirements
    if (totalRequired == 0) return 0.0;

    int totalPlaced = 0;
    placedItems.forEach((_, count) => totalPlaced += count);

    return (totalPlaced / totalRequired).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [level, unlockedItems, placedItems, isCompleted];
}
