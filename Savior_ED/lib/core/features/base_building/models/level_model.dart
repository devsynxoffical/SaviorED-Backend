import 'package:equatable/equatable.dart';
import 'level_requirements_model.dart';

class LevelModel extends Equatable {
  final int level;
  final String theme;
  final String castleModelPath;
  final LevelRequirements requirements;
  final LevelRewards rewards;

  const LevelModel({
    required this.level,
    required this.theme,
    required this.castleModelPath,
    required this.requirements,
    required this.rewards,
  });

  @override
  List<Object?> get props => [
    level,
    theme,
    castleModelPath,
    requirements,
    rewards,
  ];
}

class LevelRewards extends Equatable {
  final int xp;
  final int coins;
  final int stones;
  final int wood;

  const LevelRewards({
    required this.xp,
    required this.coins,
    required this.stones,
    required this.wood,
  });

  @override
  List<Object?> get props => [xp, coins, stones, wood];
}
