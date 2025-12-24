import mongoose from 'mongoose';

const focusSessionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    durationMinutes: {
      type: Number,
      required: true,
    },
    startTime: {
      type: Date,
    },
    endTime: {
      type: Date,
    },
    totalSeconds: {
      type: Number,
      default: 0,
    },
    isRunning: {
      type: Boolean,
      default: false,
    },
    isPaused: {
      type: Boolean,
      default: false,
    },
    focusLost: {
      type: Boolean,
      default: false,
    },
    isCompleted: {
      type: Boolean,
      default: false,
    },
    // Rewards earned
    earnedCoins: {
      type: Number,
      default: 0,
    },
    earnedStones: {
      type: Number,
      default: 0,
    },
    earnedWood: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

// Index for efficient queries
focusSessionSchema.index({ userId: 1, createdAt: -1 });
focusSessionSchema.index({ isCompleted: 1, createdAt: -1 });

const FocusSession = mongoose.model('FocusSession', focusSessionSchema);

export default FocusSession;

