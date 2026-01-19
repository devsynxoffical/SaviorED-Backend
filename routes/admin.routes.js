import express from 'express';
import { body, validationResult } from 'express-validator';
import User from '../models/User.model.js';
import FocusSession from '../models/FocusSession.model.js';
import Castle from '../models/Castle.model.js';
import TreasureChest from '../models/TreasureChest.model.js';
import generateToken from '../utils/generateToken.js';
import { protect, adminOnly } from '../middleware/auth.middleware.js';

const router = express.Router();

// @route   POST /admin/login
// @desc    Admin login
// @access  Public
router.post(
  '/login',
  [
    body('email').isEmail().normalizeEmail(),
    body('password').notEmpty(),
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

      const { email, password } = req.body;

      const user = await User.findOne({ email }).select('+password');
      if (!user || user.role !== 'admin') {
        return res.status(401).json({
          success: false,
          message: 'Invalid credentials',
        });
      }

      const isMatch = await user.comparePassword(password);
      if (!isMatch) {
        return res.status(401).json({
          success: false,
          message: 'Invalid credentials',
        });
      }

      const token = generateToken(user._id);

      res.json({
        success: true,
        token,
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
          avatar: user.avatar,
          role: user.role,
        },
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message || 'Server error',
      });
    }
  }
);

// @route   GET /admin/profile
// @desc    Get admin profile
// @access  Private (Admin)
router.get('/profile', protect, adminOnly, async (req, res) => {
  try {
    res.json({
      success: true,
      user: {
        id: req.user._id,
        email: req.user.email,
        name: req.user.name,
        avatar: req.user.avatar,
        role: req.user.role,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// @route   GET /admin/dashboard/stats
// @desc    Get dashboard statistics
// @access  Private (Admin)
router.get('/dashboard/stats', protect, adminOnly, async (req, res) => {
  try {
    const [
      totalUsers,
      activeUsers,
      totalSessions,
      completedSessions,
      totalCastles,
      totalTreasureChests,
      focusHoursResult
    ] = await Promise.all([
      User.countDocuments(),
      User.countDocuments({ isActive: true }),
      FocusSession.countDocuments(),
      FocusSession.countDocuments({ isCompleted: true }),
      Castle.countDocuments(),
      TreasureChest.countDocuments(),
      FocusSession.aggregate([
        { $match: { isCompleted: true } },
        { $group: { _id: null, totalSeconds: { $sum: "$totalSeconds" } } }
      ])
    ]);

    const totalFocusHours = focusHoursResult.length > 0
      ? focusHoursResult[0].totalSeconds / 3600
      : 0;

    res.json({
      success: true,
      stats: {
        totalUsers,
        activeUsers,
        totalFocusSessions: totalSessions,
        totalFocusHours: parseFloat(totalFocusHours.toFixed(2)),
        totalCastles,
        totalTreasureChests,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// @route   GET /admin/users
// @desc    Get all users
// @access  Private (Admin)
router.get('/users', protect, adminOnly, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const users = await User.find()
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .select('-password');

    const total = await User.countDocuments();

    res.json({
      success: true,
      users,
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

// @route   GET /admin/focus-sessions
// @desc    Get all focus sessions
// @access  Private (Admin)
router.get('/focus-sessions', protect, adminOnly, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const sessions = await FocusSession.find()
      .populate('userId', 'name email')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await FocusSession.countDocuments();

    res.json({
      success: true,
      sessions,
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

// @route   GET /admin/castle-grounds
// @desc    Get all castles
// @access  Private (Admin)
router.get('/castle-grounds', protect, adminOnly, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const castles = await Castle.find()
      .populate('userId', 'name email')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Castle.countDocuments();

    res.json({
      success: true,
      castles,
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

// @route   GET /admin/treasure-chests
// @desc    Get all treasure chests
// @access  Private (Admin)
router.get('/treasure-chests', protect, adminOnly, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const chests = await TreasureChest.find()
      .populate('userId', 'name email')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await TreasureChest.countDocuments();

    res.json({
      success: true,
      chests,
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

// @route   GET /admin/treasure-chests/stats
// @desc    Get treasure chest stats
// @access  Private (Admin)
router.get('/treasure-chests/stats', protect, adminOnly, async (req, res) => {
  try {
    const totalChests = await TreasureChest.countDocuments();
    const unlockedChests = await TreasureChest.countDocuments({ isUnlocked: true });
    const claimedChests = await TreasureChest.countDocuments({ isClaimed: true });

    res.json({
      success: true,
      stats: {
        total: totalChests,
        unlocked: unlockedChests,
        claimed: claimedChests,
        locked: totalChests - unlockedChests
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// @route   GET /admin/dashboard/activity
// @desc    Get recent activity
// @access  Private (Admin)
router.get('/dashboard/activity', protect, adminOnly, async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;

    // Get recent completed sessions as activity
    const activities = await FocusSession.find({ isCompleted: true })
      .populate('userId', 'name email avatar')
      .sort({ createdAt: -1 })
      .limit(limit);

    res.json({
      success: true,
      activities: activities.map(session => ({
        id: session._id,
        user: session.userId?.name || 'Unknown User',
        userAvatar: session.userId?.avatar,
        action: 'completed a focus session',
        details: `${Math.round(session.totalSeconds / 60)} minutes`,
        time: session.createdAt,
      })),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// @route   GET /admin/leaderboard/global
// @desc    Get global leaderboard for admin
// @access  Private (Admin)
router.get('/leaderboard/global', protect, adminOnly, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    // Rank by totalFocusHours (descending)
    const users = await User.find()
      .sort({ totalFocusHours: -1 })
      .skip(skip)
      .limit(limit)
      .select('name email avatar level totalFocusHours totalCoins experiencePoints updatedAt');

    const total = await User.countDocuments();

    // Map to expected format
    const entries = users.map((user, index) => ({
      id: user._id,
      rank: skip + index + 1,
      userId: user._id,
      name: user.name,
      email: user.email,
      avatar: user.avatar,
      level: user.level,
      coins: user.totalCoins,
      progressHours: user.totalFocusHours,
      progressMaxHours: 100, // Example max for progress bar
      updatedAt: user.updatedAt,
    }));

    res.json({
      success: true,
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

// @route   GET /admin/leaderboard/school
// @desc    Get school leaderboard for admin (Placeholder logic: Rank by XP)
// @access  Private (Admin)
router.get('/leaderboard/school', protect, adminOnly, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    // Rank by experiencePoints (descending) as proxy for "School/Academic" rank
    const users = await User.find()
      .sort({ experiencePoints: -1 })
      .skip(skip)
      .limit(limit)
      .select('name email avatar level totalFocusHours totalCoins experiencePoints updatedAt');

    const total = await User.countDocuments();

    const entries = users.map((user, index) => ({
      id: user._id,
      rank: skip + index + 1,
      userId: user._id,
      name: user.name,
      email: user.email,
      avatar: user.avatar,
      level: user.level,
      coins: user.totalCoins,
      progressHours: user.totalFocusHours,
      progressMaxHours: 100,
      updatedAt: user.updatedAt,
    }));

    res.json({
      success: true,
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

