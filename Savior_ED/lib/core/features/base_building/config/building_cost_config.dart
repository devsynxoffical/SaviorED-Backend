import '../models/resource_cost_model.dart';

class BuildingCostConfig {
  static const Map<String, ResourceCost> itemCosts = {
    // Level 1: Foundation
    'wall_basic': ResourceCost(wood: 25, stone: 5),
    'tower_small': ResourceCost(wood: 60, stone: 20, coins: 10),
    'gate_basic': ResourceCost(wood: 0, stone: 0, coins: 0),

    // Level 2: Expansion (Reduced Costs)
    'wall_medium': ResourceCost(wood: 15, stone: 5),
    'tower_watch': ResourceCost(wood: 35, stone: 15, coins: 10),
    'barracks_basic': ResourceCost(wood: 80, stone: 20, coins: 20),
    'storage_shed': ResourceCost(wood: 60, coins: 10),

    // Level 3: Fortification (Reduced)
    'wall_strong': ResourceCost(wood: 25, stone: 15),
    'tower_defense': ResourceCost(wood: 50, stone: 40, coins: 15),
    'armory': ResourceCost(wood: 120, stone: 60, coins: 40),
    'training_ground': ResourceCost(wood: 80, stone: 40, coins: 20),

    // Level 4: Commerce (Reduced)
    'market_stall': ResourceCost(wood: 40, coins: 40),
    'trading_post': ResourceCost(wood: 120, stone: 40, coins: 120),
    'warehouse': ResourceCost(wood: 160, stone: 80, coins: 40),
    'merchant_house': ResourceCost(wood: 100, stone: 20, coins: 60),

    // Level 5: Production (Reduced)
    'workshop_basic': ResourceCost(wood: 120, stone: 80, coins: 60),
    'forge': ResourceCost(wood: 80, stone: 200, coins: 120),
    'quarry': ResourceCost(wood: 200, stone: 40),
    'lumber_mill': ResourceCost(wood: 80, stone: 80, coins: 80),

    // Level 6: Defense (Reduced)
    'wall_fortress': ResourceCost(wood: 30, stone: 50),
    'tower_battle': ResourceCost(wood: 80, stone: 160, coins: 40),
    'command_center': ResourceCost(wood: 200, stone: 320, coins: 200),
    'barracks_complex': ResourceCost(wood: 160, stone: 120, coins: 80),

    // Level 7: Culture (Reduced)
    'library': ResourceCost(wood: 400, stone: 200, coins: 200),
    'temple': ResourceCost(wood: 200, stone: 400, coins: 320),
    'statue': ResourceCost(stone: 160, coins: 80),
    'garden': ResourceCost(wood: 120, coins: 80),

    // Level 8: Advanced (Reduced)
    'workshop_advanced': ResourceCost(wood: 240, stone: 240, coins: 160),
    'research_lab': ResourceCost(wood: 400, stone: 400, coins: 400),
    'barracks_advanced': ResourceCost(wood: 320, stone: 240, coins: 160),
    'tower_advanced': ResourceCost(wood: 160, stone: 320, coins: 120),

    // Level 9: Master (Reduced)
    'wall_master': ResourceCost(wood: 80, stone: 120),
    'tower_master': ResourceCost(wood: 240, stone: 480, coins: 200),
    'grand_hall': ResourceCost(wood: 800, stone: 800, coins: 800),
    'workshop_master': ResourceCost(wood: 600, stone: 600, coins: 400),

    // Level 10: Legendary (Reduced)
    'wall_legendary': ResourceCost(wood: 200, stone: 200),
    'tower_legendary': ResourceCost(wood: 400, stone: 800, coins: 400),
    'grand_palace': ResourceCost(wood: 2000, stone: 2000, coins: 2000),
    'gate_legendary': ResourceCost(wood: 800, stone: 800, coins: 800),
  };

  static const Map<String, String> upgradePaths = {
    // Walls
    'wall_basic': 'wall_medium',
    'wall_medium': 'wall_strong',
    'wall_strong': 'wall_fortress',
    'wall_fortress': 'wall_master',
    'wall_master': 'wall_legendary',

    // Towers
    'tower_small': 'tower_watch',
    'tower_watch': 'tower_defense',
    'tower_defense': 'tower_battle',
    'tower_battle': 'tower_advanced',
    'tower_advanced': 'tower_master',
    'tower_master': 'tower_legendary',

    // Gates
    // 'gate_basic': 'gate_legendary', // Removed illogical jump L1 -> L10
    // Barracks
    'barracks_basic': 'barracks_complex',
    'barracks_complex': 'barracks_advanced',

    // Workshops
    'workshop_basic': 'workshop_advanced',
    'workshop_advanced': 'workshop_master',
  };

  static String? getNextTier(String currentTemplateId) {
    return upgradePaths[currentTemplateId];
  }

  static ResourceCost getCost(String templateId) {
    return itemCosts[templateId] ?? const ResourceCost();
  }
}
