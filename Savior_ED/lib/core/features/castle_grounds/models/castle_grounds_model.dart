import 'package:equatable/equatable.dart';

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
      levelName: castleData['levelName'] ?? castleData['level_name'] ?? 'CASTLE',
      progressPercentage: (castleData['progressPercentage'] ?? 
          castleData['progress_percentage'] ?? 0).toDouble(),
      nextLevel: castleData['nextLevel'] ?? castleData['next_level'],
      castleImage: castleData['castleImage'] ?? castleData['castle_image'],
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
      'updated_at': updatedAt?.toIso8601String(),
    };
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
        updatedAt,
      ];
}

