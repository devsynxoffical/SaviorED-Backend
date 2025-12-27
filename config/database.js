import mongoose from 'mongoose';

let isConnected = false;
let connectionAttempts = 0;
const MAX_RETRIES = 5;
const RETRY_DELAY = 5000; // 5 seconds

/**
 * Connect to MongoDB with retry logic
 * Server will continue running even if connection fails initially
 */
const connectDB = async (retryCount = 0) => {
  try {
    // Use MONGO_URL (Railway) as primary, fallback to MONGODB_URI (local)
    const mongoURI = process.env.MONGO_URL || process.env.MONGODB_URI || 'mongodb://localhost:27017/saviored';
    
    if (retryCount === 0) {
      console.log(`🔗 Connecting to MongoDB...`);
      console.log(`📍 Using: ${process.env.MONGO_URL ? 'MONGO_URL' : process.env.MONGODB_URI ? 'MONGODB_URI' : 'default'}`);
      console.log(`📍 Connection: ${mongoURI.replace(/:[^:@]+@/, ':****@')}`); // Hide password in logs
    } else {
      console.log(`🔄 Retrying MongoDB connection (attempt ${retryCount + 1}/${MAX_RETRIES})...`);
    }
    
    const conn = await mongoose.connect(mongoURI, {
      serverSelectionTimeoutMS: 10000, // 10 second timeout
    });

    isConnected = true;
    connectionAttempts = 0;
    
    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
    console.log(`📊 Database: ${conn.connection.name}`);
    console.log(`🔌 Connection State: ${conn.connection.readyState === 1 ? 'Connected' : 'Disconnected'}`);
    
    // Handle connection events
    mongoose.connection.on('error', (err) => {
      console.error(`❌ MongoDB connection error: ${err.message}`);
      isConnected = false;
    });

    mongoose.connection.on('disconnected', () => {
      console.warn('⚠️ MongoDB disconnected. Attempting to reconnect...');
      isConnected = false;
      // Auto-reconnect after delay
      setTimeout(() => connectDB(0), RETRY_DELAY);
    });

    mongoose.connection.on('reconnected', () => {
      console.log('✅ MongoDB reconnected');
      isConnected = true;
    });

    return true;
  } catch (error) {
    connectionAttempts++;
    isConnected = false;
    
    console.error(`❌ Error connecting to MongoDB (attempt ${retryCount + 1}): ${error.message}`);
    
    if (retryCount < MAX_RETRIES - 1) {
      console.log(`⏳ Retrying in ${RETRY_DELAY / 1000} seconds...`);
      // Retry after delay
      setTimeout(() => connectDB(retryCount + 1), RETRY_DELAY);
    } else {
      console.error('❌ Max retry attempts reached. Server will continue without database connection.');
      console.error('💡 Database-dependent endpoints will return errors until connection is established.');
      console.error('💡 Check your MongoDB connection string in environment variables:');
      console.error('   - Railway: MONGO_URL should be set automatically');
      console.error('   - Local: Set MONGODB_URI or ensure MongoDB is running');
      console.error('💡 The server will continue running and retry connection in background.');
      
      // Don't exit - let server continue running
      // Set up periodic retry
      setInterval(() => {
        if (!isConnected) {
          console.log('🔄 Background retry: Attempting MongoDB connection...');
          connectDB(0);
        }
      }, RETRY_DELAY * 2); // Retry every 10 seconds in background
    }
    
    return false;
  }
};

/**
 * Check if database is connected
 */
export const isDBConnected = () => {
  return isConnected && mongoose.connection.readyState === 1;
};

/**
 * Middleware to check database connection before handling requests
 */
export const requireDB = (req, res, next) => {
  if (!isDBConnected()) {
    return res.status(503).json({
      success: false,
      message: 'Database connection unavailable. Please try again in a few moments.',
      error: 'SERVICE_UNAVAILABLE',
    });
  }
  next();
};

export default connectDB;

