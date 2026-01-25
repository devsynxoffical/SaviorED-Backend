import express from 'express';
import TreasureChest from '../models/TreasureChest.model.js';
import User from '../models/User.model.js';
import Castle from '../models/Castle.model.js';
import GlobalSetting from '../models/GlobalSetting.model.js';
import { protect } from '../middleware/auth.middleware.js';

const router = express.Router();

// Helper to get admin configured rewards
const getChestRewards = async () => {
  const coinSetting = await GlobalSetting.findOne({ key: 'CHEST_REWARD_COINS' });
  const woodSetting = await GlobalSetting.findOne({ key: 'CHEST_REWARD_WOOD' });
  const stoneSetting = await GlobalSetting.findOne({ key: 'CHEST_REWARD_STONE' });

  return {
    coins: coinSetting ? parseInt(coinSetting.value) : 150,
    wood: woodSetting ? parseInt(woodSetting.value) : 50,
    stones: stoneSetting ? parseInt(stoneSetting.value) : 25,
  };
};

// Helper to get dynamic unlock minutes
const getChestUnlockMinutes = async () => {
  const setting = await GlobalSetting.findOne({ key: 'CHEST_UNLOCK_MINUTES' });
  return setting ? parseInt(setting.value) : 60;
};

// @route   GET /api/treasure-chests/my-chest
// @desc    Get user's treasure chest and calculate dynamic progress
// @access  Private
router.get('/my-chest', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    let chest = await TreasureChest.findOne({ userId: req.user._id })
      .sort({ createdAt: -1 });

    // 1. Get dynamic unlock interval (e.g. 60 mins)
    const unlockMinutes = await getChestUnlockMinutes();

    // 2. Calculate dynamic progress based on the interval
    const totalMinutes = (user.totalFocusHours || 0) * 60;
    const minutesInCurrentCycle = Math.max(0, totalMinutes - (user.lastClaimedFocusMinutes || 0));

    // Progress capped at the dynamic limit (100%)
    const rawProgress = (minutesInCurrentCycle / unlockMinutes) * 100;
    const progressPercentage = Math.min(Math.floor(rawProgress), 100);
    const isUnlocked = progressPercentage >= 100;

    // 3. Create/Update chest state
    if (!chest) {
      chest = await TreasureChest.create({
        userId: req.user._id,
        progressPercentage,
        isUnlocked,
        isClaimed: false,
      });
    } else {
      // If the chest was claimed but we have enough minutes for a RELOAD (the cycle reset)
      // we reset the claimed flag.
      if (chest.isClaimed && minutesInCurrentCycle < unlockMinutes) {
        // Stay claimed until they build up focus again or if we want to reset immediately
        // Let's keep it simple: progress shows current build-up.
      }

      chest.progressPercentage = progressPercentage;
      chest.isUnlocked = isUnlocked;

      // Reset claim status if a new cycle is starting
      if (minutesInCurrentCycle < 1 && chest.isClaimed) {
        chest.isClaimed = false;
      }

      await chest.save();
    }

    res.json({
      success: true,
      chest: {
        id: chest._id,
        userId: chest.userId,
        progressPercentage: chest.progressPercentage,
        isUnlocked: chest.isUnlocked,
        isClaimed: chest.isClaimed,
        totalMinutes: Math.floor(totalMinutes),
        minutesInCurrentCycle: Math.floor(minutesInCurrentCycle),
        unlockMinutes: unlockMinutes,
        minutesRemaining: Math.max(0, unlockMinutes - Math.floor(minutesInCurrentCycle)),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// @route   PUT /api/treasure-chests/claim
// @desc    Claim treasure chest rewards and reset cycle
// @access  Private
router.put('/claim', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    const chest = await TreasureChest.findOne({ userId: req.user._id }).sort({ createdAt: -1 });

    if (!user || !chest) {
      return res.status(404).json({ success: false, message: 'Data not found' });
    }

    // 1. Get dynamic unlock interval
    const unlockMinutes = await getChestUnlockMinutes();

    // 2. Verify eligibility
    const totalMinutes = (user.totalFocusHours || 0) * 60;
    const minutesInCurrentCycle = totalMinutes - (user.lastClaimedFocusMinutes || 0);

    if (minutesInCurrentCycle < unlockMinutes && !chest.isUnlocked) {
      return res.status(400).json({
        success: false,
        message: `Chest is still locked! Focus ${unlockMinutes} minutes to unlock.`,
      });
    }

    if (chest.isClaimed) {
      return res.status(400).json({
        success: false,
        message: 'Reward already claimed for this cycle.',
      });
    }

    // 3. Get Rewards from Admin Settings
    const rewards = await getChestRewards();

    // 4. Apply rewards to Castle
    let castle = await Castle.findOne({ userId: user._id });
    if (!castle) {
      castle = await Castle.create({ userId: user._id });
    }

    castle.coins += rewards.coins;
    castle.wood += rewards.wood;
    castle.stones += rewards.stones;
    await castle.save();

    // 5. Update User state (Reset the cycle by the exact unlock value)
    user.lastClaimedFocusMinutes += unlockMinutes;
    user.totalCoins += rewards.coins; // Also track lifetime coins on user
    await user.save();

    // 6. Update Chest model
    chest.isClaimed = true;
    chest.claimedAt = new Date();
    chest.progressPercentage = 0; // Reset for visual feedback
    chest.isUnlocked = false;
    await chest.save();

    res.json({
      success: true,
      message: 'REWARDS CLAIMED!',
      rewards,
      chest,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

export default router;

