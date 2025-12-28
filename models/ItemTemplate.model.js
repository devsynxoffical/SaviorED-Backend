import mongoose from 'mongoose';

const itemTemplateSchema = new mongoose.Schema(
  {
    itemId: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    name: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      default: '',
    },
    category: {
      type: String,
      required: true,
      enum: ['collectible', 'equipment', 'consumable', 'component'],
      index: true,
    },
    rarity: {
      type: String,
      required: true,
      enum: ['common', 'rare', 'epic', 'legendary'],
      default: 'common',
      index: true,
    },
    iconName: {
      type: String,
      required: true,
      default: 'star',
    },
    colorHex: {
      type: String,
      required: true,
      default: '#808080',
    },
    stackable: {
      type: Boolean,
      default: true,
    },
    maxStack: {
      type: Number,
      default: 999,
    },
    sellable: {
      type: Boolean,
      default: false,
    },
    sellPrice: {
      type: Number,
      default: 0,
    },
    buyable: {
      type: Boolean,
      default: false,
    },
    buyPrice: {
      type: Number,
      default: 0,
    },
    usable: {
      type: Boolean,
      default: false,
    },
    useEffect: {
      type: {
        type: String,
        enum: ['bonus', 'consumable', 'upgrade'],
      },
      value: Number,
      duration: Number, // Duration in seconds for temporary effects
    },
    equipmentSlot: {
      type: String,
      enum: ['helmet', 'armor', 'accessory', null],
      default: null,
    },
    equipmentBonus: {
      type: {
        xpMultiplier: Number, // e.g., 1.1 for 10% XP boost
        focusTimeBonus: Number, // Bonus minutes
        coinMultiplier: Number,
      },
      default: null,
    },
    craftingRecipe: {
      components: [
        {
          itemId: String,
          quantity: Number,
        },
      ],
      resultQuantity: {
        type: Number,
        default: 1,
      },
    },
    obtainedFrom: {
      type: String,
      enum: ['treasure_chest', 'focus_session', 'achievement', 'shop', 'crafting'],
      default: 'focus_session',
    },
  },
  {
    timestamps: true,
  }
);

// Indexes for efficient queries
itemTemplateSchema.index({ category: 1, rarity: 1 });
itemTemplateSchema.index({ itemId: 1 });

const ItemTemplate = mongoose.model('ItemTemplate', itemTemplateSchema);

export default ItemTemplate;

