import express from 'express';
import { body, validationResult } from 'express-validator';
import UserItem from '../models/UserItem.model.js';
import ItemTemplate from '../models/ItemTemplate.model.js';
import { protect } from '../middleware/auth.middleware.js';

const router = express.Router();

// @route   GET /api/inventory
// @desc    Get user's inventory
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const { category, rarity, search } = req.query;

    // Build query
    const query = { userId: req.user._id };

    // Get user items
    let userItems = await UserItem.find(query).sort({ obtainedAt: -1 });

    // Get item templates for these items
    const itemIds = userItems.map(item => item.itemId);
    const itemTemplates = await ItemTemplate.find({
      itemId: { $in: itemIds },
    });

    // Create a map of itemId -> template
    const templateMap = new Map();
    itemTemplates.forEach(template => {
      templateMap.set(template.itemId, template);
    });

    // Combine user items with templates
    let items = userItems
      .map(userItem => {
        const template = templateMap.get(userItem.itemId);
        if (!template) return null; // Skip if template not found

        const item = {
          id: userItem._id.toString(),
          itemId: userItem.itemId,
          name: template.name,
          description: template.description,
          quantity: userItem.quantity,
          category: template.category,
          rarity: template.rarity,
          iconName: template.iconName,
          colorHex: template.colorHex,
          stackable: template.stackable,
          maxStack: template.maxStack,
          usable: template.usable,
          equipmentSlot: template.equipmentSlot,
          obtainedAt: userItem.obtainedAt,
          lastUsedAt: userItem.lastUsedAt,
        };

        // Filter by category if provided
        if (category && category !== 'all') {
          if (item.category !== category) return null;
        }

        // Filter by rarity if provided
        if (rarity && rarity !== 'all') {
          if (item.rarity !== rarity) return null;
        }

        // Filter by search term if provided
        if (search) {
          const searchLower = search.toLowerCase();
          if (
            !item.name.toLowerCase().includes(searchLower) &&
            !item.description.toLowerCase().includes(searchLower)
          ) {
            return null;
          }
        }

        return item;
      })
      .filter(item => item !== null);

    // Sort items
    items.sort((a, b) => {
      // Sort by rarity (legendary > epic > rare > common)
      const rarityOrder = { legendary: 4, epic: 3, rare: 2, common: 1 };
      const rarityDiff = (rarityOrder[b.rarity] || 0) - (rarityOrder[a.rarity] || 0);
      if (rarityDiff !== 0) return rarityDiff;

      // Then by name
      return a.name.localeCompare(b.name);
    });

    res.json({
      success: true,
      inventory: {
        items,
        totalItems: items.reduce((sum, item) => sum + item.quantity, 0),
        uniqueItems: items.length,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// @route   GET /api/inventory/items/:itemId
// @desc    Get item details
// @access  Private
router.get('/items/:itemId', protect, async (req, res) => {
  try {
    const { itemId } = req.params;

    // Get user item
    const userItem = await UserItem.findOne({
      userId: req.user._id,
      itemId: itemId,
    });

    if (!userItem) {
      return res.status(404).json({
        success: false,
        message: 'Item not found in inventory',
      });
    }

    // Get item template
    const template = await ItemTemplate.findOne({ itemId: itemId });

    if (!template) {
      return res.status(404).json({
        success: false,
        message: 'Item template not found',
      });
    }

    res.json({
      success: true,
      item: {
        id: userItem._id.toString(),
        itemId: userItem.itemId,
        name: template.name,
        description: template.description,
        quantity: userItem.quantity,
        category: template.category,
        rarity: template.rarity,
        iconName: template.iconName,
        colorHex: template.colorHex,
        stackable: template.stackable,
        maxStack: template.maxStack,
        usable: template.usable,
        useEffect: template.useEffect,
        equipmentSlot: template.equipmentSlot,
        equipmentBonus: template.equipmentBonus,
        sellable: template.sellable,
        sellPrice: template.sellPrice,
        obtainedAt: userItem.obtainedAt,
        lastUsedAt: userItem.lastUsedAt,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// @route   POST /api/inventory/items/:itemId/use
// @desc    Use an item
// @access  Private
router.post(
  '/items/:itemId/use',
  protect,
  [
    body('quantity').optional().isInt({ min: 1 }).withMessage('Quantity must be at least 1'),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          errors: errors.array(),
        });
      }

      const { itemId } = req.params;
      const { quantity = 1 } = req.body;

      // Get user item
      const userItem = await UserItem.findOne({
        userId: req.user._id,
        itemId: itemId,
      });

      if (!userItem) {
        return res.status(404).json({
          success: false,
          message: 'Item not found in inventory',
        });
      }

      if (userItem.quantity < quantity) {
        return res.status(400).json({
          success: false,
          message: 'Not enough items',
        });
      }

      // Get item template
      const template = await ItemTemplate.findOne({ itemId: itemId });

      if (!template) {
        return res.status(404).json({
          success: false,
          message: 'Item template not found',
        });
      }

      if (!template.usable) {
        return res.status(400).json({
          success: false,
          message: 'Item is not usable',
        });
      }

      // Update quantity
      userItem.quantity -= quantity;
      userItem.lastUsedAt = new Date();

      if (userItem.quantity <= 0) {
        await userItem.deleteOne();
      } else {
        await userItem.save();
      }

      res.json({
        success: true,
        message: 'Item used successfully',
        effect: template.useEffect,
        remainingQuantity: Math.max(0, userItem.quantity),
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message || 'Server error',
      });
    }
  }
);

// @route   DELETE /api/inventory/items/:itemId
// @desc    Discard items from inventory
// @access  Private
router.delete(
  '/items/:itemId',
  protect,
  [
    body('quantity').optional().isInt({ min: 1 }).withMessage('Quantity must be at least 1'),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          errors: errors.array(),
        });
      }

      const { itemId } = req.params;
      const { quantity } = req.body;

      // Get user item
      const userItem = await UserItem.findOne({
        userId: req.user._id,
        itemId: itemId,
      });

      if (!userItem) {
        return res.status(404).json({
          success: false,
          message: 'Item not found in inventory',
        });
      }

      if (quantity && userItem.quantity < quantity) {
        return res.status(400).json({
          success: false,
          message: 'Not enough items to discard',
        });
      }

      // Delete item or update quantity
      if (!quantity || userItem.quantity <= quantity) {
        await userItem.deleteOne();
      } else {
        userItem.quantity -= quantity;
        await userItem.save();
      }

      res.json({
        success: true,
        message: 'Item discarded successfully',
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message || 'Server error',
      });
    }
  }
);

// @route   GET /api/inventory/templates
// @desc    Get item templates (catalogue)
// @access  Private
router.get('/templates', protect, async (req, res) => {
  try {
    const { category, rarity } = req.query;

    const query = {};
    if (category && category !== 'all') {
      query.category = category;
    }
    if (rarity && rarity !== 'all') {
      query.rarity = rarity;
    }

    const templates = await ItemTemplate.find(query).sort({ name: 1 });

    res.json({
      success: true,
      templates: templates.map(template => ({
        itemId: template.itemId,
        name: template.name,
        description: template.description,
        category: template.category,
        rarity: template.rarity,
        iconName: template.iconName,
        colorHex: template.colorHex,
        stackable: template.stackable,
        maxStack: template.maxStack,
        usable: template.usable,
        buyable: template.buyable,
        buyPrice: template.buyPrice,
        sellable: template.sellable,
        sellPrice: template.sellPrice,
      })),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

export default router;

