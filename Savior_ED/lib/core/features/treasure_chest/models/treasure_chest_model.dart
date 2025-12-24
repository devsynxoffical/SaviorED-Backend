import 'package:equatable/equatable.dart';

/// Reward Badge model
class RewardBadgeModel extends Equatable {
  final String id;
  final String title;
  final String iconName;
  final String colorHex;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const RewardBadgeModel({
    required this.id,
    required this.title,
    required this.iconName,
    required this.colorHex,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory RewardBadgeModel.fromJson(Map<String, dynamic> json) {
    return RewardBadgeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      iconName: json['icon_name'] as String,
      colorHex: json['color_hex'] as String,
      isUnlocked: json['is_unlocked'] as bool,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon_name': iconName,
      'color_hex': colorHex,
      'is_unlocked': isUnlocked,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        iconName,
        colorHex,
        isUnlocked,
        unlockedAt,
      ];
}

/// Treasure Chest model
class TreasureChestModel extends Equatable {
  final String id;
  final String userId;
  final double progressPercentage;
  final bool isUnlocked;
  final bool isClaimed;
  final List<RewardBadgeModel> rewards;
  final DateTime? unlockedAt;
  final DateTime? claimedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TreasureChestModel({
    required this.id,
    required this.userId,
    required this.progressPercentage,
    required this.isUnlocked,
    required this.isClaimed,
    required this.rewards,
    this.unlockedAt,
    this.claimedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory TreasureChestModel.fromJson(Map<String, dynamic> json) {
    // Handle nested response from backend
    final chestData = json['chest'] ?? json;
    final id = chestData['id'] ?? chestData['_id'];
    
    return TreasureChestModel(
      id: id.toString(),
      userId: (chestData['userId'] ?? chestData['user_id'] ?? '').toString(),
      progressPercentage: (chestData['progressPercentage'] ?? 
          chestData['progress_percentage'] ?? 0).toDouble(),
      isUnlocked: chestData['isUnlocked'] ?? chestData['is_unlocked'] ?? false,
      isClaimed: chestData['isClaimed'] ?? chestData['is_claimed'] ?? false,
      rewards: (chestData['rewards'] as List<dynamic>?)
          ?.map((reward) => RewardBadgeModel.fromJson(
                reward as Map<String, dynamic>,
              ))
          .toList() ?? [],
      unlockedAt: chestData['unlockedAt'] != null
          ? DateTime.parse(chestData['unlockedAt'] as String)
          : chestData['unlocked_at'] != null
              ? DateTime.parse(chestData['unlocked_at'] as String)
              : null,
      claimedAt: chestData['claimedAt'] != null
          ? DateTime.parse(chestData['claimedAt'] as String)
          : chestData['claimed_at'] != null
              ? DateTime.parse(chestData['claimed_at'] as String)
              : null,
      createdAt: chestData['createdAt'] != null
          ? DateTime.parse(chestData['createdAt'] as String)
          : chestData['created_at'] != null
              ? DateTime.parse(chestData['created_at'] as String)
              : null,
      updatedAt: chestData['updatedAt'] != null
          ? DateTime.parse(chestData['updatedAt'] as String)
          : chestData['updated_at'] != null
              ? DateTime.parse(chestData['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'progress_percentage': progressPercentage,
      'is_unlocked': isUnlocked,
      'is_claimed': isClaimed,
      'rewards': rewards.map((reward) => reward.toJson()).toList(),
      'unlocked_at': unlockedAt?.toIso8601String(),
      'claimed_at': claimedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        progressPercentage,
        isUnlocked,
        isClaimed,
        rewards,
        unlockedAt,
        claimedAt,
        createdAt,
        updatedAt,
      ];
}

