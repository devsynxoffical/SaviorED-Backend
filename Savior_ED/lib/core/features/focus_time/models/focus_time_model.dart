import 'package:equatable/equatable.dart';

/// Focus Time model
class FocusTimeModel extends Equatable {
  final String id;
  final String userId;
  final int durationMinutes;
  final DateTime? startTime;
  final DateTime? endTime;
  final int totalSeconds;
  final bool isRunning;
  final bool isPaused;
  final bool focusLost;
  final bool isCompleted;
  final int? earnedCoins;
  final int? earnedStones;
  final int? earnedWood;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FocusTimeModel({
    required this.id,
    required this.userId,
    required this.durationMinutes,
    this.startTime,
    this.endTime,
    required this.totalSeconds,
    required this.isRunning,
    required this.isPaused,
    required this.focusLost,
    required this.isCompleted,
    this.earnedCoins,
    this.earnedStones,
    this.earnedWood,
    this.createdAt,
    this.updatedAt,
  });

  factory FocusTimeModel.fromJson(Map<String, dynamic> json) {
    // Handle both snake_case from backend and camelCase
    final id = json['id'] ?? json['_id'];
    return FocusTimeModel(
      id: id.toString(),
      userId: (json['userId'] ?? json['user_id'] ?? json['userId']).toString(),
      durationMinutes: json['durationMinutes'] ?? json['duration_minutes'] ?? 0,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : json['start_time'] != null
              ? DateTime.parse(json['start_time'] as String)
              : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : json['end_time'] != null
              ? DateTime.parse(json['end_time'] as String)
              : null,
      totalSeconds: json['totalSeconds'] ?? json['total_seconds'] ?? 0,
      isRunning: json['isRunning'] ?? json['is_running'] ?? false,
      isPaused: json['isPaused'] ?? json['is_paused'] ?? false,
      focusLost: json['focusLost'] ?? json['focus_lost'] ?? false,
      isCompleted: json['isCompleted'] ?? json['is_completed'] ?? false,
      earnedCoins: json['earnedCoins'] ?? json['earned_coins'],
      earnedStones: json['earnedStones'] ?? json['earned_stones'],
      earnedWood: json['earnedWood'] ?? json['earned_wood'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'duration_minutes': durationMinutes,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'total_seconds': totalSeconds,
      'is_running': isRunning,
      'is_paused': isPaused,
      'focus_lost': focusLost,
      'is_completed': isCompleted,
      'earned_coins': earnedCoins,
      'earned_stones': earnedStones,
      'earned_wood': earnedWood,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        durationMinutes,
        startTime,
        endTime,
        totalSeconds,
        isRunning,
        isPaused,
        focusLost,
        isCompleted,
        earnedCoins,
        earnedStones,
        earnedWood,
        createdAt,
        updatedAt,
      ];
}

