import 'package:equatable/equatable.dart';
import 'placed_item_model.dart';

/// Castle Grounds model
class CastleGroundsModel extends Equatable {
  final String id;
  final String userId;
  final int coins;
  final int stones;
  final int wood;
  final int level;
  final String levelName; // e.g., "CASTLE", "ROYAL FORTRESS"
  final double progressPercentage;
  final int? nextLevel;
  final String? castleImage;
  final List<PlacedItemModel> placedItems;
  final DateTime? updatedAt;

  const CastleGroundsModel({
    required this.id,
    required this.userId,
    required this.coins,
    required this.stones,
    required this.wood,
    required this.level,
    required this.levelName,
    required this.progressPercentage,
    this.nextLevel,
    this.castleImage,
    this.placedItems = const [],
    this.updatedAt,
  });

  factory CastleGroundsModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['_id'];
    final castleData = json['castle'] ?? json; // Handle nested response
    return CastleGroundsModel(
      id: id.toString(),
      userId: (castleData['userId'] ?? castleData['user_id'] ?? '').toString(),
      coins: castleData['coins'] ?? 0,
      stones: castleData['stones'] ?? 0,
      wood: castleData['wood'] ?? 0,
      level: castleData['level'] ?? 1,
      levelName:
          castleData['levelName'] ?? castleData['level_name'] ?? 'CASTLE',
      progressPercentage:
          (castleData['progressPercentage'] ??
                  castleData['progress_percentage'] ??
                  0)
              .toDouble(),
      nextLevel: castleData['nextLevel'] ?? castleData['next_level'],
      castleImage: castleData['castleImage'] ?? castleData['castle_image'],
      placedItems:
          (castleData['placedItems'] as List? ??
                  castleData['placed_items'] as List? ??
                  [])
              .map(
                (item) =>
                    PlacedItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      updatedAt: castleData['updatedAt'] != null
          ? DateTime.parse(castleData['updatedAt'] as String)
          : castleData['updated_at'] != null
          ? DateTime.parse(castleData['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'coins': coins,
      'stones': stones,
      'wood': wood,
      'level': level,
      'level_name': levelName,
      'progress_percentage': progressPercentage,
      'next_level': nextLevel,
      'castle_image': castleImage,
      'placed_items': placedItems.map((item) => item.toJson()).toList(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CastleGroundsModel copyWith({
    String? id,
    String? userId,
    int? coins,
    int? stones,
    int? wood,
    int? level,
    String? levelName,
    double? progressPercentage,
    int? nextLevel,
    String? castleImage,
    List<PlacedItemModel>? placedItems,
    DateTime? updatedAt,
  }) {
    return CastleGroundsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      coins: coins ?? this.coins,
      stones: stones ?? this.stones,
      wood: wood ?? this.wood,
      level: level ?? this.level,
      levelName: levelName ?? this.levelName,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      nextLevel: nextLevel ?? this.nextLevel,
      castleImage: castleImage ?? this.castleImage,
      placedItems: placedItems ?? this.placedItems,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    coins,
    stones,
    wood,
    level,
    levelName,
    progressPercentage,
    nextLevel,
    castleImage,
    placedItems,
    updatedAt,
  ];
}
