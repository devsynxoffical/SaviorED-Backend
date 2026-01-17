import 'package:equatable/equatable.dart';

/// Model for items placed on the base
class PlacedItemModel extends Equatable {
  final String id;
  final String itemType; // 'tower', 'wall', 'building', etc.
  final String itemId; // Specific item ID like 'tower_level_1'
  final int gridX;
  final int gridY;
  final double rotation; // Rotation in degrees (0-360)
  final bool isFlipped;
  final DateTime placedAt;

  const PlacedItemModel({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.gridX,
    required this.gridY,
    this.rotation = 0,
    this.isFlipped = false,
    required this.placedAt,
  });

  factory PlacedItemModel.fromJson(Map<String, dynamic> json) {
    return PlacedItemModel(
      id: json['id'] ?? json['_id'] ?? '',
      itemType: json['itemType'] ?? json['item_type'] ?? '',
      itemId: json['itemId'] ?? json['item_id'] ?? '',
      gridX: json['gridX'] ?? json['grid_x'] ?? 0,
      gridY: json['gridY'] ?? json['grid_y'] ?? 0,
      rotation: (json['rotation'] ?? 0).toDouble(),
      isFlipped: json['isFlipped'] ?? json['is_flipped'] ?? false,
      placedAt: json['placedAt'] != null
          ? DateTime.parse(json['placedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemType': itemType,
      'itemId': itemId,
      'gridX': gridX,
      'gridY': gridY,
      'rotation': rotation,
      'isFlipped': isFlipped,
      'placedAt': placedAt.toIso8601String(),
    };
  }

  PlacedItemModel copyWith({
    String? id,
    String? itemType,
    String? itemId,
    int? gridX,
    int? gridY,
    double? rotation,
    bool? isFlipped,
    DateTime? placedAt,
  }) {
    return PlacedItemModel(
      id: id ?? this.id,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      rotation: rotation ?? this.rotation,
      isFlipped: isFlipped ?? this.isFlipped,
      placedAt: placedAt ?? this.placedAt,
    );
  }

  @override
  List<Object> get props => [
    id,
    itemType,
    itemId,
    gridX,
    gridY,
    rotation,
    isFlipped,
  ];
}
