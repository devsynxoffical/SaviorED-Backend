import mongoose from 'mongoose';
import dotenv from 'dotenv';
import User from '../models/User.model.js';
import connectDB from '../config/database.js';

dotenv.config();

const createAdmin = async () => {
  try {
    await connectDB();

    const adminEmail = process.env.ADMIN_EMAIL || 'admin@saviored.com';
    const adminPassword = process.env.ADMIN_PASSWORD || 'admin123';

    // Check if admin already exists
    const existingAdmin = await User.findOne({ email: adminEmail });
    
    if (existingAdmin) {
      if (existingAdmin.role === 'admin') {
        console.log('✅ Admin user already exists');
        process.exit(0);
      } else {
        // Update existing user to admin
        existingAdmin.role = 'admin';
        existingAdmin.password = adminPassword;
        await existingAdmin.save();
        console.log('✅ Existing user updated to admin');
        process.exit(0);
      }
    }

    // Create new admin user
    const admin = await User.create({
      email: adminEmail,
      password: adminPassword,
      name: 'Admin User',
      role: 'admin',
      authMethod: 'email',
    });

    console.log('✅ Admin user created successfully');
    console.log(`   Email: ${adminEmail}`);
    console.log(`   Password: ${adminPassword}`);
    console.log('   Please change the password after first login!');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating admin:', error);
    process.exit(1);
  }
};

createAdmin();

