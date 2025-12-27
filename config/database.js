import mongoose from 'mongoose';

const connectDB = async () => {
  try {
    // Support both MONGO_URL (Railway) and MONGODB_URI (local)
    const mongoURI = process.env.MONGO_URL || process.env.MONGODB_URI || 'mongodb://localhost:27017/saviored';
    
    console.log(`🔗 Connecting to MongoDB...`);
    console.log(`📍 Connection string: ${mongoURI.replace(/:[^:@]+@/, ':****@')}`); // Hide password in logs
    
    const conn = await mongoose.connect(mongoURI);

    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
    console.log(`📊 Database: ${conn.connection.name}`);
  } catch (error) {
    console.error(`❌ Error connecting to MongoDB: ${error.message}`);
    console.error('💡 Check your MongoDB connection string in environment variables');
    console.error('💡 Railway: Use MONGO_URL variable');
    console.error('💡 Local: Use MONGODB_URI variable or ensure MongoDB is running');
    process.exit(1);
  }
};

export default connectDB;

