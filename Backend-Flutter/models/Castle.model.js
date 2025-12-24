import mongoose from 'mongoose';

const castleSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
      index: true,
    },
    coins: {
      type: Number,
      default: 0,
    },
    stones: {
      type: Number,
      default: 0,
    },
    wood: {
      type: Number,
      default: 0,
    },
    level: {
      type: Number,
      default: 1,
    },
    levelName: {
      type: String,
      default: 'CASTLE',
    },
    progressPercentage: {
      type: Number,
      default: 0,
      min: 0,
      max: 100,
    },
    nextLevel: {
      type: Number,
      default: 2,
    },
    castleImage: {
      type: String,
    },
    // Level requirements
    levelRequirements: {
      coins: { type: Number, default: 100 },
      stones: { type: Number, default: 50 },
      wood: { type: Number, default: 30 },
    },
  },
  {
    timestamps: true,
  }
);

// Calculate progress percentage
castleSchema.methods.calculateProgress = function () {
  const { coins, stones, wood } = this;
  const { coins: reqCoins, stones: reqStones, wood: reqWood } = this.levelRequirements;
  
  const coinProgress = Math.min((coins / reqCoins) * 100, 100);
  const stoneProgress = Math.min((stones / reqStones) * 100, 100);
  const woodProgress = Math.min((wood / reqWood) * 100, 100);
  
  this.progressPercentage = (coinProgress + stoneProgress + woodProgress) / 3;
  return this.progressPercentage;
};

// Check if user can level up
castleSchema.methods.canLevelUp = function () {
  const { coins, stones, wood } = this;
  const { coins: reqCoins, stones: reqStones, wood: reqWood } = this.levelRequirements;
  
  return coins >= reqCoins && stones >= reqStones && wood >= reqWood;
};

// Level up
castleSchema.methods.levelUp = function () {
  if (!this.canLevelUp()) {
    throw new Error('Cannot level up: insufficient resources');
  }
  
  const { coins, stones, wood } = this;
  const { coins: reqCoins, stones: reqStones, wood: reqWood } = this.levelRequirements;
  
  this.coins -= reqCoins;
  this.stones -= reqStones;
  this.wood -= reqWood;
  this.level += 1;
  this.nextLevel = this.level + 1;
  this.levelName = `LEVEL ${this.level}`;
  
  // Update requirements for next level (increase by 20% each level)
  this.levelRequirements = {
    coins: Math.floor(reqCoins * 1.2),
    stones: Math.floor(reqStones * 1.2),
    wood: Math.floor(reqWood * 1.2),
  };
  
  this.calculateProgress();
  return this;
};

const Castle = mongoose.model('Castle', castleSchema);

export default Castle;

