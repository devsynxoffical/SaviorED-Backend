import express from 'express';
import Castle from '../models/Castle.model.js';
import { protect } from '../middleware/auth.middleware.js';

const router = express.Router();

// @route   GET /api/castles/my-castle
// @desc    Get user's castle
// @access  Private
router.get('/my-castle', protect, async (req, res) => {
  try {
    let castle = await Castle.findOne({ userId: req.user._id });

    // Create castle if it doesn't exist
    if (!castle) {
      castle = await Castle.create({
        userId: req.user._id,
        level: 1,
        levelName: 'CASTLE',
        progressPercentage: 0,
        nextLevel: 2,
        levelRequirements: {
          coins: 100,
          stones: 50,
          wood: 30,
        },
      });
    }

    res.json({
      success: true,
      castle: {
        id: castle._id,
        userId: castle.userId,
        coins: castle.coins,
        stones: castle.stones,
        wood: castle.wood,
        level: castle.level,
        levelName: castle.levelName,
        progressPercentage: castle.progressPercentage,
        nextLevel: castle.nextLevel,
        castleImage: castle.castleImage,
        levelRequirements: castle.levelRequirements,
        levelRequirements: castle.levelRequirements,
        updatedAt: castle.updatedAt,
        layout: castle.layout || [], // Return layout field
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// @route   PUT /api/castles/layout
// @route   PUT /api/castles/update-layout
// @desc    Update castle layout
// @access  Private
router.put(['/layout', '/update-layout'], protect, async (req, res) => {
  try {
    const { layout, items, placed_items, level } = req.body;

    let castle = await Castle.findOne({ userId: req.user._id });
    if (!castle) {
      return res.status(404).json({ success: false, message: 'Castle not found' });
    }

    // Support all possible layout keys from different frontend versions
    castle.layout = layout || placed_items || items || [];
    castle.markModified('layout');

    // Update level if provided
    if (level) castle.level = level;

    await castle.save();

    res.json({
      success: true,
      message: 'Layout updated successfully',
      castle: {
        id: castle._id,
        level: castle.level,
        coins: castle.coins,
        stones: castle.stones,
        wood: castle.wood,
        layout: castle.layout,
      }
    });
  } catch (error) {
    console.error('Layout update error:', error);
    res.status(500).json({ success: false, message: 'Server error updating layout' });
  }
});

// @route   POST /api/castles/spend-resources
// @desc    Spend coins, wood, or stone
// @access  Private
router.post('/spend-resources', protect, async (req, res) => {
  try {
    const { coins, wood, stone } = req.body;

    let castle = await Castle.findOne({ userId: req.user._id });
    if (!castle) {
      return res.status(404).json({ success: false, message: 'Castle not found' });
    }

    // Validation
    const spendCoins = parseInt(coins) || 0;
    const spendWood = parseInt(wood) || 0;
    const spendStones = parseInt(stone) || 0;

    if (castle.coins < spendCoins || castle.wood < spendWood || castle.stones < spendStones) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient resources',
        current: { coins: castle.coins, wood: castle.wood, stones: castle.stones }
      });
    }

    // Deduct
    castle.coins -= spendCoins;
    castle.wood -= spendWood;
    castle.stones -= spendStones;

    await castle.save();

    res.json({
      success: true,
      message: 'Resources spent successfully',
      castle: {
        coins: castle.coins,
        wood: castle.wood,
        stones: castle.stones,
        level: castle.level
      }
    });
  } catch (error) {
    console.error('Spend resources error:', error);
    res.status(500).json({ success: false, message: 'Server error processing transaction' });
  }
});

// @route   PUT /api/castles/level-up
// @desc    Level up castle
// @access  Private
router.put('/level-up', protect, async (req, res) => {
  try {
    const castle = await Castle.findOne({ userId: req.user._id });

    if (!castle) {
      return res.status(404).json({
        success: false,
        message: 'Castle not found',
      });
    }

    if (!castle.canLevelUp()) {
      return res.status(400).json({
        success: false,
        message: 'Cannot level up: insufficient resources',
        requirements: castle.levelRequirements,
        current: {
          coins: castle.coins,
          stones: castle.stones,
          wood: castle.wood,
        },
      });
    }

    castle.levelUp();
    await castle.save();

    // Update user level
    const User = (await import('../models/User.model.js')).default;
    await User.findByIdAndUpdate(req.user._id, { level: castle.level });

    res.json({
      success: true,
      castle: {
        id: castle._id,
        userId: castle.userId,
        coins: castle.coins,
        stones: castle.stones,
        wood: castle.wood,
        level: castle.level,
        levelName: castle.levelName,
        progressPercentage: castle.progressPercentage,
        nextLevel: castle.nextLevel,
        levelRequirements: castle.levelRequirements,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// @route   GET /api/castles/:userId
// @desc    Get castle by user ID
// @access  Private
router.get('/:userId', protect, async (req, res) => {
  try {
    const castle = await Castle.findOne({ userId: req.params.userId });

    if (!castle) {
      return res.status(404).json({
        success: false,
        message: 'Castle not found',
      });
    }

    res.json({
      success: true,
      castle: {
        id: castle._id,
        userId: castle.userId,
        coins: castle.coins,
        stones: castle.stones,
        wood: castle.wood,
        level: castle.level,
        levelName: castle.levelName,
        progressPercentage: castle.progressPercentage,
        nextLevel: castle.nextLevel,
        castleImage: castle.castleImage,
        layout: castle.layout || [], // Allow viewing other user's layout
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

