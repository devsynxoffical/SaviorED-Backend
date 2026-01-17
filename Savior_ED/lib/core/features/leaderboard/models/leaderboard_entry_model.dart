import 'package:equatable/equatable.dart';

/// Leaderboard Entry model
class LeaderboardEntryModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String level;
  final int rank;
  final int? coins;
  final double? progressHours;
  final double? progressMaxHours;
  final String? avatar;
  final String?
  buttonText; // e.g., "VIEW PROFILE", "CLAIM REWARD", "COINS EARNED"
  final String?
  buttonType; // e.g., "view_profile", "claim_reward", "coins_earned"
  final String? shieldColorHex; // Color hex for shield icon
  final String? castleColorHex; // Color hex for castle icon
  final DateTime? updatedAt;

  const LeaderboardEntryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.level,
    required this.rank,
    this.coins,
    this.progressHours,
    this.progressMaxHours,
    this.avatar,
    this.buttonText,
    this.buttonType,
    this.shieldColorHex,
    this.castleColorHex,
    this.updatedAt,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown').toString(),
      level: (json['level'] ?? 'Level 1').toString(),
      rank: (json['rank'] ?? 0) as int,
      coins: json['coins'] != null ? (json['coins'] as num).toInt() : null,
      progressHours: (json['progressHours'] ?? json['progress_hours']) != null
          ? (json['progressHours'] ?? json['progress_hours'] as num).toDouble()
          : null,
      progressMaxHours:
          (json['progressMaxHours'] ?? json['progress_max_hours']) != null
          ? (json['progressMaxHours'] ?? json['progress_max_hours'] as num)
                .toDouble()
          : null,
      avatar: json['avatar'] as String?,
      buttonText: (json['buttonText'] ?? json['button_text']) as String?,
      buttonType: (json['buttonType'] ?? json['button_type']) as String?,
      shieldColorHex:
          (json['shieldColorHex'] ?? json['shield_color_hex']) as String?,
      castleColorHex:
          (json['castleColorHex'] ?? json['castle_color_hex']) as String?,
      updatedAt: (json['updatedAt'] ?? json['updated_at']) != null
          ? DateTime.parse((json['updatedAt'] ?? json['updated_at']) as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'level': level,
      'rank': rank,
      'coins': coins,
      'progress_hours': progressHours,
      'progress_max_hours': progressMaxHours,
      'avatar': avatar,
      'button_text': buttonText,
      'button_type': buttonType,
      'shield_color_hex': shieldColorHex,
      'castle_color_hex': castleColorHex,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    level,
    rank,
    coins,
    progressHours,
    progressMaxHours,
    avatar,
    buttonText,
    buttonType,
    shieldColorHex,
    castleColorHex,
    updatedAt,
  ];
}

/// Leaderboard model
class LeaderboardModel extends Equatable {
  final String id;
  final String type; // 'global' or 'school'
  final List<LeaderboardEntryModel> entries;
  final DateTime? updatedAt;

  const LeaderboardModel({
    required this.id,
    required this.type,
    required this.entries,
    this.updatedAt,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map(
                (entry) => LeaderboardEntryModel.fromJson(
                  entry as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      updatedAt: (json['updatedAt'] ?? json['updated_at']) != null
          ? DateTime.parse((json['updatedAt'] ?? json['updated_at']) as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'entries': entries.map((entry) => entry.toJson()).toList(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, type, entries, updatedAt];
}
