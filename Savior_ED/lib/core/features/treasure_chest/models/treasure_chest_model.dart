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
    // Handle both camelCase (from backend) and snake_case
    // Backend sends rewards as objects without IDs, so we generate one
    final id =
        json['id']?.toString() ??
        json['_id']?.toString() ??
        '${json['title']}_${json['iconName'] ?? json['icon_name'] ?? 'default'}';

    return RewardBadgeModel(
      id: id,
      title: json['title'] as String? ?? 'Unknown',
      iconName: json['iconName'] ?? json['icon_name'] ?? 'star',
      colorHex: json['colorHex'] ?? json['color_hex'] ?? '#3b82f6',
      isUnlocked: json['isUnlocked'] ?? json['is_unlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'].toString())
          : json['unlocked_at'] != null
          ? DateTime.tryParse(json['unlocked_at'].toString())
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
  final int unlockMinutes;
  final int minutesInCurrentCycle;
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
    this.unlockMinutes = 60,
    this.minutesInCurrentCycle = 0,
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
      progressPercentage:
          (chestData['progressPercentage'] ??
                  chestData['progress_percentage'] ??
                  0)
              .toDouble(),
      isUnlocked: chestData['isUnlocked'] ?? chestData['is_unlocked'] ?? false,
      isClaimed: chestData['isClaimed'] ?? chestData['is_claimed'] ?? false,
      unlockMinutes:
          (chestData['unlockMinutes'] ?? chestData['unlock_minutes'] ?? 60)
              as int,
      minutesInCurrentCycle:
          (chestData['minutesInCurrentCycle'] ??
                  chestData['minutes_in_current_cycle'] ??
                  0)
              as int,
      rewards:
          (chestData['rewards'] as List<dynamic>?)?.asMap().entries.map((
            entry,
          ) {
            final reward = entry.value as Map<String, dynamic>;
            // Add index as ID if no ID is provided
            if (reward['id'] == null && reward['_id'] == null) {
              reward['id'] = entry.key.toString();
            }
            return RewardBadgeModel.fromJson(reward);
          }).toList() ??
          [],
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
      'unlock_minutes': unlockMinutes,
      'minutes_in_current_cycle': minutesInCurrentCycle,
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
    unlockMinutes,
    minutesInCurrentCycle,
    rewards,
    unlockedAt,
    claimedAt,
    createdAt,
    updatedAt,
  ];
}
