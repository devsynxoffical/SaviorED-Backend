import express from 'express';
import { body, validationResult } from 'express-validator';
import FocusSession from '../models/FocusSession.model.js';
import User from '../models/User.model.js';
import Castle from '../models/Castle.model.js';
import TreasureChest from '../models/TreasureChest.model.js';
import { protect } from '../middleware/auth.middleware.js';

const router = express.Router();

// @route   POST /api/focus-sessions
// @desc    Create a new focus session
// @access  Private
router.post(
  '/',
  protect,
  [
    body('durationMinutes').isInt({ min: 1 }),
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

      const { durationMinutes } = req.body;

      const session = await FocusSession.create({
        userId: req.user._id,
        durationMinutes,
        isRunning: true,
        startTime: new Date(),
      });

      res.status(201).json({
        success: true,
        session: {
          id: session._id,
          userId: session.userId,
          durationMinutes: session.durationMinutes,
          startTime: session.startTime,
          isRunning: session.isRunning,
          isPaused: session.isPaused,
          focusLost: session.focusLost,
          isCompleted: session.isCompleted,
          totalSeconds: session.totalSeconds,
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

// @route   GET /api/focus-sessions
// @desc    Get user's focus sessions
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const sessions = await FocusSession.find({ userId: req.user._id })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await FocusSession.countDocuments({ userId: req.user._id });

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

// @route   GET /api/focus-sessions/:id
// @desc    Get focus session by ID
// @access  Private
router.get('/:id', protect, async (req, res) => {
  try {
    const session = await FocusSession.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Session not found',
      });
    }

    res.json({
      success: true,
      session,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// @route   PUT /api/focus-sessions/:id/complete
// @desc    Complete a focus session
// @access  Private
router.put('/:id/complete', protect, async (req, res) => {
  try {
    const session = await FocusSession.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Session not found',
      });
    }

    if (session.isCompleted) {
      return res.status(400).json({
        success: false,
        message: 'Session already completed',
      });
    }

    // Calculate rewards (1 coin per minute, 0.5 stones per minute, 1 wood per minute)
    // Use totalSeconds from body for accurate calculation
    const finalSeconds = req.body.totalSeconds !== undefined ? req.body.totalSeconds : session.totalSeconds;
    const minutes = Math.floor(finalSeconds / 60);
    const earnedCoins = Math.floor(minutes * 1);
    const earnedStones = Math.floor(minutes * 0.5);
    const earnedWood = Math.floor(minutes * 1.0);

    // Calculate XP (10 XP per minute of focused time)
    const earnedXP = minutes * 10;

    console.log(`🎁 Completing Session with ${finalSeconds}s (${minutes} mins):`);
    console.log(`   - Coins: ${earnedCoins}, Wood: ${earnedWood}, Stones: ${earnedStones}, XP: ${earnedXP}`);

    session.isCompleted = true;
    session.isRunning = false;
    session.endTime = new Date();
    session.totalSeconds = finalSeconds;
    session.earnedCoins = earnedCoins;
    session.earnedStones = earnedStones;
    session.earnedWood = earnedWood;

    await session.save();

    // Update user stats
    const user = await User.findById(req.user._id);
    user.totalSessions += 1;
    user.completedSessions += 1;
    user.totalFocusHours += minutes / 60;
    user.totalCoins += earnedCoins;

    // Add XP and check for level up
    const levelUpResult = user.addXP(earnedXP);
    await user.save();

    // Update castle resources
    const castle = await Castle.findOne({ userId: req.user._id });
    if (castle) {
      castle.coins += earnedCoins;
      castle.stones += earnedStones;
      castle.wood += earnedWood;
      castle.calculateProgress();
      await castle.save();
    }

    // Update treasure chest progress (based on completed sessions)
    const chest = await TreasureChest.findOne({ userId: req.user._id })
      .sort({ createdAt: -1 });

    if (chest) {
      // Progress increases by 5% per completed session, max 100%
      const newProgress = Math.min(chest.progressPercentage + 5, 100);
      chest.progressPercentage = newProgress;

      // Unlock chest if progress reaches 100%
      if (newProgress >= 100 && !chest.isUnlocked) {
        chest.isUnlocked = true;
        chest.unlockedAt = new Date();

        // Unlock all rewards
        chest.rewards.forEach(reward => {
          reward.isUnlocked = true;
          reward.unlockedAt = new Date();
        });
      }

      await chest.save();
    }

    res.json({
      success: true,
      session: {
        id: session._id,
        userId: session.userId,
        durationMinutes: session.durationMinutes,
        totalSeconds: session.totalSeconds,
        isCompleted: session.isCompleted,
        earnedCoins: session.earnedCoins,
        earnedStones: session.earnedStones,
        earnedWood: session.earnedWood,
        startTime: session.startTime,
        endTime: session.endTime,
      },
      rewards: {
        coins: earnedCoins,
        stones: earnedStones,
        wood: earnedWood,
        xp: earnedXP,
        levelUp: levelUpResult,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// @route   PUT /api/focus-sessions/:id/update
// @desc    Update focus session (pause, resume, update time)
// @access  Private
router.put('/:id/update', protect, async (req, res) => {
  try {
    const session = await FocusSession.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!session) {
      return res.status(404).json({
        success: false,
        message: 'Session not found',
      });
    }

    const { totalSeconds, isPaused, isRunning, focusLost } = req.body;

    if (totalSeconds !== undefined) session.totalSeconds = totalSeconds;
    if (isPaused !== undefined) session.isPaused = isPaused;
    if (isRunning !== undefined) session.isRunning = isRunning;
    if (focusLost !== undefined) session.focusLost = focusLost;

    await session.save();

    res.json({
      success: true,
      session,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

export default router;

