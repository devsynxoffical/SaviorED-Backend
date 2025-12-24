import mongoose from 'mongoose';

const rewardBadgeSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  iconName: {
    type: String,
    required: true,
  },
  colorHex: {
    type: String,
    required: true,
  },
  isUnlocked: {
    type: Boolean,
    default: false,
  },
  unlockedAt: {
    type: Date,
  },
});

const treasureChestSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    progressPercentage: {
      type: Number,
      default: 0,
      min: 0,
      max: 100,
    },
    isUnlocked: {
      type: Boolean,
      default: false,
    },
    isClaimed: {
      type: Boolean,
      default: false,
    },
    rewards: [rewardBadgeSchema],
    unlockedAt: {
      type: Date,
    },
    claimedAt: {
      type: Date,
    },
  },
  {
    timestamps: true,
  }
);

// Index for efficient queries
treasureChestSchema.index({ userId: 1, createdAt: -1 });

const TreasureChest = mongoose.model('TreasureChest', treasureChestSchema);

export default TreasureChest;

