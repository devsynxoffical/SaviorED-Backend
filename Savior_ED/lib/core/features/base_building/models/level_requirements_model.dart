import 'package:equatable/equatable.dart';

class LevelRequirements extends Equatable {
  final int level;
  final List<ItemRequirement> requiredItems;
  final bool completionCriteria; // Placeholder for more complex criteria

  const LevelRequirements({
    required this.level,
    required this.requiredItems,
    this.completionCriteria = true,
  });

  @override
  List<Object?> get props => [level, requiredItems, completionCriteria];
}

class ItemRequirement extends Equatable {
  final String itemTemplateId;
  final int quantity;
  final bool mustPlace;

  const ItemRequirement({
    required this.itemTemplateId,
    required this.quantity,
    this.mustPlace = true,
  });

  @override
  List<Object?> get props => [itemTemplateId, quantity, mustPlace];
}
