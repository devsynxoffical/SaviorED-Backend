import '../models/level_model.dart';
import '../models/level_requirements_model.dart';

class LevelConfig {
  static const List<LevelModel> levels = [
    // Level 1: Foundation
    LevelModel(
      level: 1,
      theme: 'Foundation',
      castleModelPath: 'assets/images/level1/source/poly.glb',
      requirements: LevelRequirements(
        level: 1,
        requiredItems: [
          ItemRequirement(itemTemplateId: 'wall_basic', quantity: 4),
          ItemRequirement(itemTemplateId: 'tower_small', quantity: 4),
          ItemRequirement(itemTemplateId: 'gate_basic', quantity: 1),
        ],
      ),
      rewards: LevelRewards(xp: 100, coins: 50, stones: 20, wood: 10),
    ),

    // Level 2: Expansion
    LevelModel(
      level: 2,
      theme: 'Expansion',
      castleModelPath:
          'assets/models/castles/castle_level_2.glb', // Placeholder
      requirements: LevelRequirements(
        level: 2,
        requiredItems: [
          ItemRequirement(itemTemplateId: 'wall_medium', quantity: 6),
          ItemRequirement(itemTemplateId: 'tower_watch', quantity: 3),
          ItemRequirement(itemTemplateId: 'barracks_basic', quantity: 1),
          ItemRequirement(itemTemplateId: 'storage_shed', quantity: 1),
        ],
      ),
      rewards: LevelRewards(xp: 200, coins: 100, stones: 40, wood: 20),
    ),

    // Level 3: Fortification
    LevelModel(
      level: 3,
      theme: 'Fortification',
      castleModelPath: 'assets/models/castles/castle_level_3.glb',
      requirements: LevelRequirements(
        level: 3,
        requiredItems: [
          ItemRequirement(itemTemplateId: 'wall_strong', quantity: 8),
          ItemRequirement(itemTemplateId: 'tower_defense', quantity: 4),
          ItemRequirement(itemTemplateId: 'armory', quantity: 1),
          ItemRequirement(itemTemplateId: 'training_ground', quantity: 1),
        ],
      ),
      rewards: LevelRewards(xp: 300, coins: 150, stones: 60, wood: 30),
    ),

    // Level 4: Commerce
    LevelModel(
      level: 4,
      theme: 'Commerce',
      castleModelPath: 'assets/models/castles/castle_level_4.glb',
      requirements: LevelRequirements(
        level: 4,
        requiredItems: [
          ItemRequirement(itemTemplateId: 'market_stall', quantity: 3),
          ItemRequirement(itemTemplateId: 'trading_post', quantity: 1),
          ItemRequirement(itemTemplateId: 'warehouse', quantity: 1),
          ItemRequirement(itemTemplateId: 'merchant_house', quantity: 2),
        ],
      ),
      rewards: LevelRewards(xp: 400, coins: 200, stones: 80, wood: 40),
    ),

    // Level 5: Production
    LevelModel(
      level: 5,
      theme: 'Production',
      castleModelPath: 'assets/models/castles/castle_level_5.glb',
      requirements: LevelRequirements(
        level: 5,
        requiredItems: [
          ItemRequirement(itemTemplateId: 'workshop_basic', quantity: 2),
          ItemRequirement(itemTemplateId: 'forge', quantity: 1),
          ItemRequirement(itemTemplateId: 'quarry', quantity: 1),
          ItemRequirement(itemTemplateId: 'lumber_mill', quantity: 1),
        ],
      ),
      rewards: LevelRewards(xp: 500, coins: 250, stones: 100, wood: 50),
    ),

    // Level 6: Defense
    LevelModel(
      level: 6,
      theme: 'Defense',
      castleModelPath: 'assets/models/castles/castle_level_6.glb',
      requirements: LevelRequirements(
        level: 6,
        requiredItems: [
          ItemRequirement(itemTemplateId: 'wall_fortress', quantity: 10),
          ItemRequirement(itemTemplateId: 'tower_battle', quantity: 5),
          ItemRequirement(itemTemplateId: 'command_center', quantity: 1),
          ItemRequirement(itemTemplateId: 'barracks_complex', quantity: 2),
        ],
      ),
      rewards: LevelRewards(xp: 600, coins: 300, stones: 120, wood: 60),
    ),

    // Level 7: Culture
    LevelModel(
      level: 7,
      theme: 'Culture',
      castleModelPath: 'assets/models/castles/castle_level_7.glb',
      requirements: LevelRequirements(
        level: 7,
        requiredItems: [
          ItemRequirement(itemTemplateId: 'library', quantity: 1),
          ItemRequirement(itemTemplateId: 'temple', quantity: 1),
          ItemRequirement(itemTemplateId: 'statue', quantity: 3),
          ItemRequirement(itemTemplateId: 'garden', quantity: 2),
        ],
      ),
      rewards: LevelRewards(xp: 700, coins: 350, stones: 140, wood: 70),
    ),

    // Level 8: Advanced
    LevelModel(
      level: 8,
      theme: 'Advanced',
      castleModelPath: 'assets/models/castles/castle_level_8.glb',
      requirements: LevelRequirements(
        level: 8,
        requiredItems: [
          ItemRequirement(itemTemplateId: 'workshop_advanced', quantity: 2),
          ItemRequirement(itemTemplateId: 'research_lab', quantity: 1),
          ItemRequirement(itemTemplateId: 'barracks_advanced', quantity: 2),
          ItemRequirement(itemTemplateId: 'tower_advanced', quantity: 4),
        ],
      ),
      rewards: LevelRewards(xp: 800, coins: 400, stones: 160, wood: 80),
    ),

    // Level 9: Master
    LevelModel(
      level: 9,
      theme: 'Master',
      castleModelPath: 'assets/models/castles/castle_level_9.glb',
      requirements: LevelRequirements(
        level: 9,
        requiredItems: [
          ItemRequirement(itemTemplateId: 'wall_master', quantity: 15),
          ItemRequirement(itemTemplateId: 'tower_master', quantity: 6),
          ItemRequirement(itemTemplateId: 'grand_hall', quantity: 1),
          ItemRequirement(itemTemplateId: 'workshop_master', quantity: 1),
        ],
      ),
      rewards: LevelRewards(xp: 900, coins: 450, stones: 180, wood: 90),
    ),

    // Level 10: Legendary
    LevelModel(
      level: 10,
      theme: 'Legendary',
      castleModelPath: 'assets/models/castles/castle_level_10.glb',
      requirements: LevelRequirements(
        level: 10,
        requiredItems: [
          ItemRequirement(itemTemplateId: 'wall_legendary', quantity: 20),
          ItemRequirement(itemTemplateId: 'tower_legendary', quantity: 8),
          ItemRequirement(itemTemplateId: 'grand_palace', quantity: 1),
          ItemRequirement(itemTemplateId: 'gate_legendary', quantity: 2),
        ],
      ),
      rewards: LevelRewards(xp: 1000, coins: 500, stones: 200, wood: 100),
    ),
  ];

  static LevelModel getLevel(int level) {
    return levels.firstWhere(
      (l) => l.level == level,
      orElse: () => levels.first,
    );
  }
}
