import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import passport from 'passport';
import connectDB from './config/database.js';
import './config/passport.js'; // Initialize passport strategies
import authRoutes from './routes/auth.routes.js';
import userRoutes from './routes/user.routes.js';
import focusSessionRoutes from './routes/focusSession.routes.js';
import castleRoutes from './routes/castle.routes.js';
import leaderboardRoutes from './routes/leaderboard.routes.js';
import treasureChestRoutes from './routes/treasureChest.routes.js';
import adminRoutes from './routes/admin.routes.js';

// Load environment variables
dotenv.config();

// Connect to database
connectDB();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(passport.initialize());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'SaviorED API is running' });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/focus-sessions', focusSessionRoutes);
app.use('/api/castles', castleRoutes);
app.use('/api/leaderboard', leaderboardRoutes);
app.use('/api/treasure-chests', treasureChestRoutes);
app.use('/admin', adminRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📱 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🌐 API Base URL: http://localhost:${PORT}`);
  console.log(`📚 Health Check: http://localhost:${PORT}/health`);
  console.log(`\n📋 Available Endpoints:`);
  console.log(`   - POST /api/auth/register - Register new user`);
  console.log(`   - POST /api/auth/login - Login user`);
  console.log(`   - GET /api/auth/me - Get current user`);
  console.log(`   - GET /api/users/profile - Get user profile`);
  console.log(`   - POST /api/focus-sessions - Create focus session`);
  console.log(`   - GET /api/castles/my-castle - Get user's castle`);
  console.log(`   - GET /api/leaderboard/global - Get global leaderboard`);
  console.log(`   - GET /api/treasure-chests/my-chest - Get treasure chest`);
  console.log(`   - POST /admin/login - Admin login`);
});

export default app;

