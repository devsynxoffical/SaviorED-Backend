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
        updatedAt: castle.updatedAt,
        layout: castle.layout || [],
        inventory: castle.inventory || {}, // Added inventory
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
    const { layout, items, placed_items, level, progressPercentage } = req.body;
    const incomingItems = layout || placed_items || items || [];

    let castle = await Castle.findOne({ userId: req.user._id });
    if (!castle) {
      return res.status(404).json({ success: false, message: 'Castle not found' });
    }

    // 1. Calculate ownership stats
    // A user owns: Placed items (old) + Inventory count
    const ownedCounts = {};
    (castle.layout || []).forEach(item => {
      ownedCounts[item.itemId] = (ownedCounts[item.itemId] || 0) + 1;
    });
    // Handle Inventory correctly (Mongoose Map vs POJO)
    if (castle.inventory) {
      if (castle.inventory instanceof Map) {
        castle.inventory.forEach((count, id) => {
          ownedCounts[id] = (ownedCounts[id] || 0) + count;
        });
      } else {
        // Fallback for POJO
        for (const [id, count] of Object.entries(castle.inventory)) {
          ownedCounts[id] = (ownedCounts[id] || 0) + count;
        }
      }
    }

    // 2. Map incoming counts
    const incomingCounts = {};
    incomingItems.forEach(item => {
      incomingCounts[item.itemId] = (incomingCounts[item.itemId] || 0) + 1;
    });

    // 3. Update Inventory (Buildings in stock)
    // Inventory = Owned - Placed (new)
    const newInventory = {};
    const keys = new Set([...Object.keys(ownedCounts), ...Object.keys(incomingCounts)]);

    for (const id of keys) {
      const owned = ownedCounts[id] || 0;
      const placing = incomingCounts[id] || 0;

      if (placing > owned) {
        // App should have called /spend-resources first, but we'll allow free gates or debug
        // For now, let's just log it or allow it if free
        console.warn(`User placing more ${id} than owned! (${placing} > ${owned})`);
      }

      const stock = Math.max(0, owned - placing);
      if (stock > 0) newInventory[id] = stock;
    }

    castle.layout = incomingItems;
    castle.inventory = newInventory;
    castle.markModified('layout');
    castle.markModified('inventory');

    // Update level if provided
    if (level) castle.level = level;
    if (progressPercentage !== undefined) castle.progressPercentage = progressPercentage;

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
        inventory: castle.inventory
      }
    });
  } catch (error) {
    console.error('Layout update error:', error);
    res.status(500).json({ success: false, message: 'Server error updating layout' });
  }
});

// @route   POST /api/castles/spend-resources
// @desc    Spend coins, wood, or stone (Purchase building)
// @access  Private
router.post('/spend-resources', protect, async (req, res) => {
  try {
    const { coins, wood, stone, itemId } = req.body;

    let castle = await Castle.findOne({ userId: req.user._id });
    if (!castle) {
      return res.status(404).json({ success: false, message: 'Castle not found' });
    }

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

    // Add to Inventory
    if (itemId) {
      if (!castle.inventory || !(castle.inventory instanceof Map)) {
        castle.inventory = new Map();
      }

      const currentStock = castle.inventory.get(itemId) || 0;
      castle.inventory.set(itemId, currentStock + 1);
      castle.markModified('inventory');
    }

    await castle.save();

    res.json({
      success: true,
      message: 'Purchase successful',
      castle: {
        coins: castle.coins,
        wood: castle.wood,
        stones: castle.stones,
        inventory: castle.inventory
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
    castle.progressPercentage = 0; // Reset progress for new level
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

