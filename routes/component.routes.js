import express from 'express';
import { body, validationResult } from 'express-validator';
import UserItem from '../models/UserItem.model.js';
import ItemTemplate from '../models/ItemTemplate.model.js';
import Castle from '../models/Castle.model.js';
import User from '../models/User.model.js';
import { protect } from '../middleware/auth.middleware.js';

const router = express.Router();

// @route   GET /api/components
// @desc    Get user's components (resources and materials)
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    // Get user's castle for resources
    const castle = await Castle.findOne({ userId: req.user._id });

    // Get component items (category: 'component')
    const componentItems = await UserItem.find({
      userId: req.user._id,
    });

    const itemIds = componentItems.map(item => item.itemId);
    const templates = await ItemTemplate.find({
      itemId: { $in: itemIds },
      category: 'component',
    });

    const templateMap = new Map();
    templates.forEach(template => {
      templateMap.set(template.itemId, template);
    });

    const materials = componentItems
      .map(userItem => {
        const template = templateMap.get(userItem.itemId);
        if (!template) return null;

        return {
          itemId: userItem.itemId,
          name: template.name,
          quantity: userItem.quantity,
          iconName: template.iconName,
          colorHex: template.colorHex,
        };
      })
      .filter(item => item !== null);

    res.json({
      success: true,
      components: {
        resources: {
          coins: castle?.coins || 0,
          stones: castle?.stones || 0,
          wood: castle?.wood || 0,
        },
        materials,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// @route   POST /api/components/craft
// @desc    Craft an item from components
// @access  Private
router.post(
  '/craft',
  protect,
  [
    body('itemId').notEmpty().withMessage('Item ID is required'),
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

      const { itemId, quantity = 1 } = req.body;

      // Get item template
      const template = await ItemTemplate.findOne({ itemId });

      if (!template) {
        return res.status(404).json({
          success: false,
          message: 'Item template not found',
        });
      }

      if (!template.craftingRecipe || !template.craftingRecipe.components || template.craftingRecipe.components.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Item cannot be crafted',
        });
      }

      // Check if user has all required components
      const requiredComponents = template.craftingRecipe.components;
      const userItems = await UserItem.find({
        userId: req.user._id,
      });

      const userItemMap = new Map();
      userItems.forEach(item => {
        userItemMap.set(item.itemId, item);
      });

      // Also check castle resources
      const castle = await Castle.findOne({ userId: req.user._id });
      const resources = {
        coins: castle?.coins || 0,
        stones: castle?.stones || 0,
        wood: castle?.wood || 0,
      };

      const consumedComponents = [];
      const resourceDeductions = { coins: 0, stones: 0, wood: 0 };

      for (const component of requiredComponents) {
        const requiredQty = component.quantity * quantity;

        // Check if it's a resource
        if (component.itemId === 'coins') {
          if (resources.coins < requiredQty) {
            return res.status(400).json({
              success: false,
              message: `Not enough coins. Required: ${requiredQty}, Have: ${resources.coins}`,
            });
          }
          resourceDeductions.coins += requiredQty;
        } else if (component.itemId === 'stones') {
          if (resources.stones < requiredQty) {
            return res.status(400).json({
              success: false,
              message: `Not enough stones. Required: ${requiredQty}, Have: ${resources.stones}`,
            });
          }
          resourceDeductions.stones += requiredQty;
        } else if (component.itemId === 'wood') {
          if (resources.wood < requiredQty) {
            return res.status(400).json({
              success: false,
              message: `Not enough wood. Required: ${requiredQty}, Have: ${resources.wood}`,
            });
          }
          resourceDeductions.wood += requiredQty;
        } else {
          // Regular item component
          const userItem = userItemMap.get(component.itemId);
          if (!userItem || userItem.quantity < requiredQty) {
            const componentTemplate = await ItemTemplate.findOne({ itemId: component.itemId });
            return res.status(400).json({
              success: false,
              message: `Not enough ${componentTemplate?.name || component.itemId}. Required: ${requiredQty}, Have: ${userItem?.quantity || 0}`,
            });
          }
          consumedComponents.push({ itemId: component.itemId, quantity: requiredQty });
        }
      }

      // Deduct resources from castle
      if (castle && (resourceDeductions.coins > 0 || resourceDeductions.stones > 0 || resourceDeductions.wood > 0)) {
        castle.coins -= resourceDeductions.coins;
        castle.stones -= resourceDeductions.stones;
        castle.wood -= resourceDeductions.wood;
        await castle.save();
      }

      // Deduct components from inventory
      for (const component of consumedComponents) {
        const userItem = userItemMap.get(component.itemId);
        userItem.quantity -= component.quantity;
        if (userItem.quantity <= 0) {
          await userItem.deleteOne();
        } else {
          await userItem.save();
        }
      }

      // Add crafted item to inventory
      const resultQuantity = (template.craftingRecipe.resultQuantity || 1) * quantity;
      let craftedUserItem = await UserItem.findOne({
        userId: req.user._id,
        itemId: itemId,
      });

      if (craftedUserItem) {
        craftedUserItem.quantity += resultQuantity;
        await craftedUserItem.save();
      } else {
        craftedUserItem = await UserItem.create({
          userId: req.user._id,
          itemId: itemId,
          quantity: resultQuantity,
        });
      }

      res.json({
        success: true,
        message: 'Item crafted successfully',
        craftedItem: {
          itemId: itemId,
          quantity: resultQuantity,
          totalQuantity: craftedUserItem.quantity,
        },
        consumedComponents: [
          ...consumedComponents,
          ...(resourceDeductions.coins > 0 ? [{ itemId: 'coins', quantity: resourceDeductions.coins }] : []),
          ...(resourceDeductions.stones > 0 ? [{ itemId: 'stones', quantity: resourceDeductions.stones }] : []),
          ...(resourceDeductions.wood > 0 ? [{ itemId: 'wood', quantity: resourceDeductions.wood }] : []),
        ],
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message || 'Server error',
      });
    }
  }
);

export default router;

