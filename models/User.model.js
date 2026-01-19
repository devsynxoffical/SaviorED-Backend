import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

const userSchema = new mongoose.Schema(
  {
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
      match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email'],
    },
    password: {
      type: String,
      minlength: [6, 'Password must be at least 6 characters'],
      select: false, // Don't return password by default
      required: function () {
        return this.authMethod === 'email';
      },
    },
    name: {
      type: String,
      trim: true,
    },
    avatar: {
      type: String,
    },
    googleId: {
      type: String,
      sparse: true,
      unique: true,
    },
    authMethod: {
      type: String,
      enum: ['email', 'google'],
      default: 'email',
    },
    role: {
      type: String,
      enum: ['user', 'admin'],
      default: 'user',
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    // Level and progress
    level: {
      type: Number,
      default: 1,
    },
    experiencePoints: {
      type: Number,
      default: 0,
    },
    totalFocusHours: {
      type: Number,
      default: 0,
    },
    totalCoins: {
      type: Number,
      default: 0,
    },
    // Stats
    totalSessions: {
      type: Number,
      default: 0,
    },
    completedSessions: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

// Hash password before saving
userSchema.pre('save', async function (next) {
  if (!this.isModified('password') || !this.password) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

// Calculate level from XP (100 XP per level, exponential growth)
userSchema.methods.calculateLevel = function () {
  // Level formula: level = floor(sqrt(XP / 100)) + 1
  // This gives: Level 1 at 0 XP, Level 2 at 100 XP, Level 3 at 400 XP, etc.
  const calculatedLevel = Math.floor(Math.sqrt(this.experiencePoints / 100)) + 1;
  if (calculatedLevel > this.level) {
    this.level = calculatedLevel;
  }
  return this.level;
};

// Add XP and update level
userSchema.methods.addXP = function (amount) {
  this.experiencePoints += amount;
  const oldLevel = this.level;
  this.calculateLevel();
  return {
    newXP: this.experiencePoints,
    oldLevel,
    newLevel: this.level,
    leveledUp: this.level > oldLevel,
  };
};

// Compare password method
userSchema.methods.comparePassword = async function (candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Remove password from JSON output
userSchema.methods.toJSON = function () {
  const obj = this.toObject();
  delete obj.password;
  return obj;
};

const User = mongoose.model('User', userSchema);

export default User;

