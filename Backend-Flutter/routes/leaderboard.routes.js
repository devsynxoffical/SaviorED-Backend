import express from 'express';
import User from '../models/User.model.js';
import FocusSession from '../models/FocusSession.model.js';
import Castle from '../models/Castle.model.js';
import { protect } from '../middleware/auth.middleware.js';

const router = express.Router();

// @route   GET /api/leaderboard/global
// @desc    Get global leaderboard
// @access  Private
router.get('/global', protect, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    // Get users sorted by total focus hours
    const users = await User.find({ isActive: true })
      .sort({ totalFocusHours: -1, level: -1 })
      .skip(skip)
      .limit(limit)
      .select('name email avatar level totalFocusHours totalCoins');

    // Get castles for these users
    const userIds = users.map(u => u._id);
    const castles = await Castle.find({ userId: { $in: userIds } });

    const castleMap = new Map(castles.map(c => [c.userId.toString(), c]));

    const entries = users.map((user, index) => {
      const castle = castleMap.get(user._id.toString());
      return {
        id: user._id.toString(),
        userId: user._id.toString(),
        name: user.name || user.email.split('@')[0],
        level: `Level ${user.level}`,
        rank: skip + index + 1,
        coins: castle?.coins || 0,
        progressHours: user.totalFocusHours || 0,
        progressMaxHours: 100, // Can be dynamic
        avatar: user.avatar,
        buttonText: 'VIEW PROFILE',
        buttonType: 'view_profile',
      };
    });

    const total = await User.countDocuments({ isActive: true });

    res.json({
      success: true,
      type: 'global',
      entries,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// @route   GET /api/leaderboard/school
// @desc    Get school leaderboard (can be filtered by school later)
// @access  Private
router.get('/school', protect, async (req, res) => {
  try {
    // For now, return global leaderboard
    // Can be filtered by school when school feature is added
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const users = await User.find({ isActive: true })
      .sort({ totalFocusHours: -1, level: -1 })
      .skip(skip)
      .limit(limit)
      .select('name email avatar level totalFocusHours totalCoins');

    const userIds = users.map(u => u._id);
    const castles = await Castle.find({ userId: { $in: userIds } });
    const castleMap = new Map(castles.map(c => [c.userId.toString(), c]));

    const entries = users.map((user, index) => {
      const castle = castleMap.get(user._id.toString());
      return {
        id: user._id.toString(),
        userId: user._id.toString(),
        name: user.name || user.email.split('@')[0],
        level: `Level ${user.level}`,
        rank: skip + index + 1,
        coins: castle?.coins || 0,
        progressHours: user.totalFocusHours || 0,
        progressMaxHours: 100,
        avatar: user.avatar,
        buttonText: 'VIEW PROFILE',
        buttonType: 'view_profile',
      };
    });

    const total = await User.countDocuments({ isActive: true });

    res.json({
      success: true,
      type: 'school',
      entries,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
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

