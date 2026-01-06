import express from 'express';
import { body, validationResult } from 'express-validator';
import User from '../models/User.model.js';
import generateToken from '../utils/generateToken.js';
import { protect } from '../middleware/auth.middleware.js';
import { requireDB } from '../config/database.js';
import passport from 'passport';
import '../config/passport.js';

const router = express.Router();

// @route   POST /api/auth/register
// @desc    Register a new user
// @access  Public
router.post(
  '/register',
  requireDB, // Ensure database is connected before processing
  [
    body('email').isEmail().normalizeEmail(),
    body('password').isLength({ min: 6 }),
    body('name').optional().trim(),
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

      const { email, password, name } = req.body;

      // Check if user exists
      const userExists = await User.findOne({ email });
      if (userExists) {
        return res.status(400).json({
          success: false,
          message: 'User already exists',
        });
      }

      // Create user
      const user = await User.create({
        email,
        password,
        name: name || email.split('@')[0],
        authMethod: 'email',
      });

      // Create initial castle for user
      const Castle = (await import('../models/Castle.model.js')).default;
      await Castle.create({
        userId: user._id,
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

      const token = generateToken(user._id);

      res.status(201).json({
        success: true,
        token,
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
          avatar: user.avatar,
          level: user.level,
          experiencePoints: user.experiencePoints || 0,
        },
      });
    } catch (error) {
      console.error('Register error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Server error',
      });
    }
  }
);

// @route   POST /api/auth/login
// @desc    Login user
// @access  Public
router.post(
  '/login',
  requireDB, // Ensure database is connected before processing
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

      // Check if user exists and get password
      const user = await User.findOne({ email }).select('+password');
      if (!user) {
        return res.status(401).json({
          success: false,
          message: 'Invalid credentials',
        });
      }

      // Check if user is active
      if (!user.isActive) {
        return res.status(401).json({
          success: false,
          message: 'Account is inactive',
        });
      }

      // Check if user has password (Google users might not have password)
      if (user.authMethod === 'google' && !user.password) {
        return res.status(401).json({
          success: false,
          message: 'Please use Google login for this account',
        });
      }

      // Check password
      if (!user.password) {
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
        },
      });
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Server error',
      });
    }
  }
);

// @route   GET /api/auth/me
// @desc    Get current user
// @access  Private
router.get('/me', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
      res.json({
        success: true,
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
          avatar: user.avatar,
          level: user.level,
          experiencePoints: user.experiencePoints,
        },
      });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// @route   GET /api/auth/google
// @desc    Google OAuth login
// @access  Public
router.get(
  '/google',
  passport.authenticate('google', {
    scope: ['profile', 'email'],
  })
);

// @route   GET /api/auth/google/callback
// @desc    Google OAuth callback
// @access  Public
router.get(
  '/google/callback',
  passport.authenticate('google', { session: false }),
  async (req, res) => {
    try {
      const token = generateToken(req.user._id);
      
      // Redirect to frontend with token
      const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:3000';
      res.redirect(`${frontendUrl}/auth/callback?token=${token}`);
    } catch (error) {
      console.error('Google callback error:', error);
      res.redirect(`${process.env.FRONTEND_URL || 'http://localhost:3000'}/login?error=auth_failed`);
    }
  }
);

// @route   POST /api/auth/forgot-password
// @desc    Request password reset
// @access  Public
router.post(
  '/forgot-password',
  [body('email').isEmail().normalizeEmail()],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          errors: errors.array(),
        });
      }

      const { email } = req.body;

      const user = await User.findOne({ email });
      if (!user) {
        // Don't reveal if user exists for security
        return res.json({
          success: true,
          message: 'If an account exists with this email, a password reset link has been sent.',
        });
      }

      if (user.authMethod === 'google') {
        return res.status(400).json({
          success: false,
          message: 'This account uses Google login. Please use Google to sign in.',
        });
      }

      // In production, send email with reset token
      // For now, just return success
      res.json({
        success: true,
        message: 'If an account exists with this email, a password reset link has been sent.',
      });
    } catch (error) {
      console.error('Forgot password error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Server error',
      });
    }
  }
);

// @route   POST /api/auth/reset-password
// @desc    Reset password with token
// @access  Public
router.post(
  '/reset-password',
  [
    body('email').isEmail().normalizeEmail(),
    body('password').isLength({ min: 6 }),
    body('token').notEmpty(),
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

      const { email, password, token } = req.body;

      const user = await User.findOne({ email }).select('+password');
      if (!user) {
        return res.status(404).json({
          success: false,
          message: 'User not found',
        });
      }

      // In production, verify token from email
      // For now, accept any token (implement proper token verification)
      user.password = password;
      await user.save();

      res.json({
        success: true,
        message: 'Password reset successfully',
      });
    } catch (error) {
      console.error('Reset password error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Server error',
      });
    }
  }
);

// @route   POST /api/auth/logout
// @desc    Logout user (client-side token removal)
// @access  Private
router.post('/logout', protect, (req, res) => {
  res.json({
    success: true,
    message: 'Logged out successfully',
  });
});

// @route   POST /api/auth/google/mobile
// @desc    Google OAuth login for mobile apps (using ID token or access token)
// @access  Public
router.post(
  '/google/mobile',
  requireDB, // Ensure database is connected before processing
  [
    // idToken is optional - if null, we'll use accessToken and email for verification
    body('idToken').optional(),
    body('accessToken').optional(),
    body('email').isEmail().withMessage('Valid email is required'),
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

      const { idToken, accessToken, email, name, photo } = req.body;

      // Validate that we have either idToken or accessToken
      if (!idToken && !accessToken) {
        return res.status(400).json({
          success: false,
          errors: [{
            type: 'field',
            value: null,
            msg: 'Either Google ID token or access token is required',
            path: 'idToken',
            location: 'body'
          }],
        });
      }

      // Verify Google credentials
      // Note: In production, you should verify the token with Google's API
      // For now, we'll create/login user based on the provided info
      
      // Check if user exists with this email
      let user = await User.findOne({ email });

      if (user) {
        // User exists, update Google info if needed
        if (!user.googleId) {
          // Store ID token if available, otherwise use access token
          user.googleId = idToken || accessToken;
          user.authMethod = 'google';
          if (photo && !user.avatar) {
            user.avatar = photo;
          }
          if (name && !user.name) {
            user.name = name;
          }
          await user.save();
        }
      } else {
        // Create new user
        user = await User.create({
          email: email,
          name: name || 'Google User',
          avatar: photo,
          googleId: idToken || accessToken, // Store token as identifier
          authMethod: 'google',
        });

        // Create initial castle for user
        const Castle = (await import('../models/Castle.model.js')).default;
        await Castle.create({
          userId: user._id,
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

      const token = generateToken(user._id);

      res.json({
        success: true,
        token,
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
          avatar: user.avatar,
          level: user.level,
          experiencePoints: user.experiencePoints || 0,
        },
      });
    } catch (error) {
      console.error('Google mobile login error:', error);
      res.status(500).json({
        success: false,
        message: error.message || 'Server error',
      });
    }
  }
);

export default router;

