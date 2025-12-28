import mongoose from 'mongoose';

const userItemSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    itemId: {
      type: String,
      required: true,
      index: true,
    },
    quantity: {
      type: Number,
      required: true,
      default: 1,
      min: 0,
    },
    obtainedAt: {
      type: Date,
      default: Date.now,
    },
    lastUsedAt: {
      type: Date,
    },
    metadata: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
  },
  {
    timestamps: true,
  }
);

// Compound index for efficient queries
userItemSchema.index({ userId: 1, itemId: 1 }, { unique: true });
userItemSchema.index({ userId: 1, obtainedAt: -1 });

const UserItem = mongoose.model('UserItem', userItemSchema);

export default UserItem;

