import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import passport from 'passport';
import connectDB, { isDBConnected } from './config/database.js';
import './config/passport.js'; // Initialize passport strategies
import authRoutes from './routes/auth.routes.js';
import userRoutes from './routes/user.routes.js';
import focusSessionRoutes from './routes/focusSession.routes.js';
import castleRoutes from './routes/castle.routes.js';
import leaderboardRoutes from './routes/leaderboard.routes.js';
import treasureChestRoutes from './routes/treasureChest.routes.js';
import inventoryRoutes from './routes/inventory.routes.js';
import componentRoutes from './routes/component.routes.js';
import adminRoutes from './routes/admin.routes.js';

// Load environment variables
dotenv.config();

// Connect to database (non-blocking - server will start even if DB connection fails)
connectDB().catch((error) => {
  console.error('Initial database connection failed, but server will continue:', error.message);
});

const app = express();
// Railway automatically sets PORT environment variable
// Use Railway's PORT or default to 5000 for local development
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors({
  origin: true, // This echoes the request origin and is the best way to handle credentials: true
  credentials: true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(passport.initialize());

// Root route for Railway health checks
app.get('/', (req, res) => {
  res.json({
    status: 'OK',
    message: 'SaviorED API is running',
    service: 'SaviorED Backend',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

// Health check
app.get('/health', (req, res) => {
  const dbStatus = isDBConnected();
  res.json({
    status: 'OK',
    message: 'SaviorED API is running',
    database: {
      connected: dbStatus,
      status: dbStatus ? 'Connected' : 'Disconnected',
    },
    timestamp: new Date().toISOString(),
  });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/focus-sessions', focusSessionRoutes);
app.use('/api/castles', castleRoutes);
app.use('/api/leaderboard', leaderboardRoutes);
app.use('/api/treasure-chests', treasureChestRoutes);
app.use('/api/inventory', inventoryRoutes);
app.use('/api/components', componentRoutes);
app.use('/admin', adminRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);

  // Check if error is database-related
  if (err.name === 'MongoServerError' || err.name === 'MongooseError' || err.message?.includes('MongoDB')) {
    const dbConnected = isDBConnected();
    return res.status(503).json({
      success: false,
      message: dbConnected
        ? 'Database operation failed. Please try again.'
        : 'Database connection unavailable. Please try again in a few moments.',
      error: 'DATABASE_ERROR',
      databaseConnected: dbConnected,
    });
  }

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

// Listen on all interfaces (0.0.0.0) - required for Railway
// Railway needs the server to bind to 0.0.0.0 to be accessible from outside
const HOST = process.env.HOST || '0.0.0.0';

// Start server - Railway will route traffic to this port
const server = app.listen(PORT, HOST, () => {
  console.log(`\n${'='.repeat(60)}`);
  console.log(`🚀 SERVER STARTED SUCCESSFULLY`);
  console.log(`${'='.repeat(60)}`);
  console.log(`📍 Host: ${HOST}`);
  console.log(`🔌 Port: ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`\n📡 Network Configuration:`);
  console.log(`   - Listening on: ${HOST}:${PORT}`);
  console.log(`   - Railway URL: https://saviored-backend-production.up.railway.app`);
  console.log(`   - Health Check: https://saviored-backend-production.up.railway.app/health`);
  console.log(`   - Root Endpoint: https://saviored-backend-production.up.railway.app/`);
  console.log(`\n📋 Available API Endpoints:`);
  console.log(`   - GET  / - Root endpoint`);
  console.log(`   - GET  /health - Health check`);
  console.log(`   - POST /api/auth/register - Register new user`);
  console.log(`   - POST /api/auth/login - Login user`);
  console.log(`   - GET  /api/auth/me - Get current user`);
  console.log(`   - GET  /api/users/profile - Get user profile`);
  console.log(`   - POST /api/focus-sessions - Create focus session`);
  console.log(`   - GET  /api/castles/my-castle - Get user's castle`);
  console.log(`   - GET  /api/leaderboard/global - Get global leaderboard`);
  console.log(`   - GET  /api/treasure-chests/my-chest - Get treasure chest`);
  console.log(`   - GET  /api/inventory - Get user inventory`);
  console.log(`   - GET  /api/components - Get user components`);
  console.log(`   - POST /admin/login - Admin login`);
  console.log(`\n💡 Railway Configuration:`);
  console.log(`   - Service must be set to "Public" in Railway dashboard`);
  console.log(`   - Check Settings → Networking → Public Networking`);
  console.log(`   - Verify service has a public domain assigned`);
  console.log(`${'='.repeat(60)}\n`);
});

// Handle server errors
server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.error(`❌ Port ${PORT} is already in use`);
  } else {
    console.error(`❌ Server error: ${error.message}`);
  }
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

export default app;

