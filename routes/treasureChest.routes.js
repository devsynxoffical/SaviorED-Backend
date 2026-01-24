import express from 'express';
import TreasureChest from '../models/TreasureChest.model.js';
import User from '../models/User.model.js';
import { protect } from '../middleware/auth.middleware.js';

const router = express.Router();

// @route   GET /api/treasure-chests/my-chest
// @desc    Get user's treasure chest
// @access  Private
router.get('/my-chest', protect, async (req, res) => {
  try {
    let chest = await TreasureChest.findOne({ userId: req.user._id })
      .sort({ createdAt: -1 });

    // Create chest if it doesn't exist
    if (!chest) {
      chest = await TreasureChest.create({
        userId: req.user._id,
        progressPercentage: 0,
        isUnlocked: false,
        isClaimed: false,
        rewards: [
          {
            title: 'First Focus',
            iconName: 'focus',
            colorHex: '#3b82f6',
            isUnlocked: false,
          },
          {
            title: 'Dedicated Learner',
            iconName: 'learner',
            colorHex: '#10b981',
            isUnlocked: false,
          },
        ],
      });
    }

    // SYNC LOGIC REMOVED: Chest progress is now independent of account-total focus hours
    // to prevent overwriting specific chest progress with lifetime stats.
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.json({
      success: true,
      chest: {
        id: chest._id,
        userId: chest.userId,
        progressPercentage: chest.progressPercentage,
        isUnlocked: chest.isUnlocked,
        isClaimed: chest.isClaimed,
        rewards: chest.rewards,
        unlockedAt: chest.unlockedAt,
        claimedAt: chest.claimedAt,
        createdAt: chest.createdAt,
        updatedAt: chest.updatedAt,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// @route   PUT /api/treasure-chests/update-progress
// @desc    Update treasure chest progress
// @access  Private
router.put('/update-progress', protect, async (req, res) => {
  try {
    const { progressPercentage } = req.body;

    let chest = await TreasureChest.findOne({ userId: req.user._id })
      .sort({ createdAt: -1 });

    if (!chest) {
      chest = await TreasureChest.create({
        userId: req.user._id,
        progressPercentage: 0,
        isUnlocked: false,
        isClaimed: false,
        rewards: [],
      });
    }

    chest.progressPercentage = Math.min(Math.max(progressPercentage || 0, 0), 100);

    // Unlock chest if progress reaches 100%
    if (chest.progressPercentage >= 100 && !chest.isUnlocked) {
      chest.isUnlocked = true;
      chest.unlockedAt = new Date();

      // Unlock all rewards
      chest.rewards.forEach(reward => {
        reward.isUnlocked = true;
        reward.unlockedAt = new Date();
      });
    }

    await chest.save();

    res.json({
      success: true,
      chest: {
        id: chest._id,
        userId: chest.userId,
        progressPercentage: chest.progressPercentage,
        isUnlocked: chest.isUnlocked,
        isClaimed: chest.isClaimed,
        rewards: chest.rewards,
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
// @desc    Claim treasure chest rewards
// @access  Private
router.put('/claim', protect, async (req, res) => {
  try {
    const chest = await TreasureChest.findOne({ userId: req.user._id })
      .sort({ createdAt: -1 });

    if (!chest) {
      return res.status(404).json({
        success: false,
        message: 'Treasure chest not found',
      });
    }

    if (!chest.isUnlocked) {
      return res.status(400).json({
        success: false,
        message: 'Treasure chest is not unlocked yet',
      });
    }

    if (chest.isClaimed) {
      return res.status(400).json({
        success: false,
        message: 'Rewards already claimed',
      });
    }

    chest.isClaimed = true;
    chest.claimedAt = new Date();
    await chest.save();

    res.json({
      success: true,
      message: 'Rewards claimed successfully',
      chest: {
        id: chest._id,
        userId: chest.userId,
        progressPercentage: chest.progressPercentage,
        isUnlocked: chest.isUnlocked,
        isClaimed: chest.isClaimed,
        rewards: chest.rewards,
        claimedAt: chest.claimedAt,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

export default router;

