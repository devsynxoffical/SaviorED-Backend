import mongoose from 'mongoose';
import dotenv from 'dotenv';
import ItemTemplate from '../models/ItemTemplate.model.js';

dotenv.config();

const items = [
  // Collectibles
  {
    itemId: 'first_focus_badge',
    name: 'First Focus Badge',
    description: 'Awarded for completing your first focus session',
    category: 'collectible',
    rarity: 'common',
    iconName: 'star',
    colorHex: '#FFD700',
    obtainedFrom: 'focus_session',
  },
  {
    itemId: 'week_streak_badge',
    name: 'Week Streak Badge',
    description: 'Maintained focus for 7 consecutive days',
    category: 'collectible',
    rarity: 'rare',
    iconName: 'fire',
    colorHex: '#FF6B35',
    obtainedFrom: 'achievement',
  },
  {
    itemId: 'focus_master_badge',
    name: 'Focus Master Badge',
    description: 'Completed 100 focus sessions',
    category: 'collectible',
    rarity: 'epic',
    iconName: 'trophy',
    colorHex: '#9B59B6',
    obtainedFrom: 'achievement',
  },
  {
    itemId: 'legendary_learner',
    name: 'Legendary Learner',
    description: 'Achieved level 50',
    category: 'collectible',
    rarity: 'legendary',
    iconName: 'star',
    colorHex: '#FFD700',
    obtainedFrom: 'achievement',
  },
  
  // Equipment
  {
    itemId: 'focus_helmet_common',
    name: 'Focus Helmet',
    description: 'A basic helmet that increases focus time',
    category: 'equipment',
    rarity: 'common',
    iconName: 'shield',
    colorHex: '#808080',
    equipmentSlot: 'helmet',
    equipmentBonus: {
      xpMultiplier: 1.05, // 5% XP boost
      focusTimeBonus: 5, // 5 minutes bonus
    },
    obtainedFrom: 'treasure_chest',
  },
  {
    itemId: 'focus_helmet_rare',
    name: 'Enhanced Focus Helmet',
    description: 'An enhanced helmet that significantly increases focus time',
    category: 'equipment',
    rarity: 'rare',
    iconName: 'shield',
    colorHex: '#3B82F6',
    equipmentSlot: 'helmet',
    equipmentBonus: {
      xpMultiplier: 1.1, // 10% XP boost
      focusTimeBonus: 10,
    },
    obtainedFrom: 'treasure_chest',
  },
  {
    itemId: 'coin_boost_accessory',
    name: 'Coin Boost Charm',
    description: 'Increases coins earned from focus sessions',
    category: 'equipment',
    rarity: 'rare',
    iconName: 'star',
    colorHex: '#FFD700',
    equipmentSlot: 'accessory',
    equipmentBonus: {
      coinMultiplier: 1.15, // 15% coin boost
    },
    obtainedFrom: 'treasure_chest',
  },
  
  // Consumables
  {
    itemId: 'xp_booster',
    name: 'XP Booster',
    description: 'Temporarily increases XP gain by 20% for 1 hour',
    category: 'consumable',
    rarity: 'common',
    iconName: 'star',
    colorHex: '#10B981',
    usable: true,
    useEffect: {
      type: 'bonus',
      value: 1.2, // 20% XP multiplier
      duration: 3600, // 1 hour in seconds
    },
    obtainedFrom: 'focus_session',
  },
  {
    itemId: 'focus_potion',
    name: 'Focus Potion',
    description: 'Extends focus session time by 15 minutes',
    category: 'consumable',
    rarity: 'rare',
    iconName: 'star',
    colorHex: '#3B82F6',
    usable: true,
    useEffect: {
      type: 'consumable',
      value: 15, // 15 minutes
      duration: 0,
    },
    obtainedFrom: 'treasure_chest',
  },
  
  // Components (Crafting Materials)
  {
    itemId: 'iron_ore',
    name: 'Iron Ore',
    description: 'Raw iron ore used for crafting',
    category: 'component',
    rarity: 'common',
    iconName: 'star',
    colorHex: '#8B4513',
    obtainedFrom: 'focus_session',
  },
  {
    itemId: 'steel_bar',
    name: 'Steel Bar',
    description: 'Refined steel bar for advanced crafting',
    category: 'component',
    rarity: 'rare',
    iconName: 'star',
    colorHex: '#708090',
    obtainedFrom: 'focus_session',
    craftingRecipe: {
      components: [
        { itemId: 'iron_ore', quantity: 5 },
        { itemId: 'coins', quantity: 100 },
      ],
      resultQuantity: 1,
    },
  },
  {
    itemId: 'magic_gem',
    name: 'Magic Gem',
    description: 'A rare magical gem',
    category: 'component',
    rarity: 'epic',
    iconName: 'star',
    colorHex: '#9B59B6',
    obtainedFrom: 'treasure_chest',
  },
  
  // Craftable Items
  {
    itemId: 'custom_helmet',
    name: 'Custom Helmet',
    description: 'Crafted helmet with moderate bonuses',
    category: 'equipment',
    rarity: 'rare',
    iconName: 'shield',
    colorHex: '#3B82F6',
    equipmentSlot: 'helmet',
    equipmentBonus: {
      xpMultiplier: 1.08,
      focusTimeBonus: 8,
    },
    craftingRecipe: {
      components: [
        { itemId: 'steel_bar', quantity: 3 },
        { itemId: 'coins', quantity: 500 },
      ],
      resultQuantity: 1,
    },
    obtainedFrom: 'crafting',
  },
];

async function seedItems() {
  try {
    // Connect to MongoDB
    const mongoURI = process.env.MONGO_URL || process.env.MONGODB_URI || 'mongodb://localhost:27017/saviored';
    await mongoose.connect(mongoURI);
    console.log('✅ Connected to MongoDB');

    // Clear existing items (optional - comment out if you want to keep existing)
    // await ItemTemplate.deleteMany({});
    // console.log('✅ Cleared existing item templates');

    // Insert items
    let created = 0;
    let updated = 0;

    for (const itemData of items) {
      const existing = await ItemTemplate.findOne({ itemId: itemData.itemId });
      
      if (existing) {
        await ItemTemplate.updateOne({ itemId: itemData.itemId }, itemData);
        updated++;
        console.log(`🔄 Updated: ${itemData.name}`);
      } else {
        await ItemTemplate.create(itemData);
        created++;
        console.log(`✅ Created: ${itemData.name}`);
      }
    }

    console.log(`\n✅ Seed completed!`);
    console.log(`   Created: ${created} items`);
    console.log(`   Updated: ${updated} items`);
    console.log(`   Total: ${items.length} items`);

    await mongoose.disconnect();
    console.log('✅ Disconnected from MongoDB');
  } catch (error) {
    console.error('❌ Error seeding items:', error);
    process.exit(1);
  }
}

// Run seed
seedItems();

