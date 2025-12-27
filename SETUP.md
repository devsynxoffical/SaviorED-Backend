# Backend Setup & Testing Guide

## Quick Start

1. **Install Dependencies**
```bash
cd Backend-Flutter
npm install
```

2. **Configure Environment**
Create a `.env` file:
```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/saviored
JWT_SECRET=your_super_secret_jwt_key_change_this
JWT_EXPIRE=7d
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_CALLBACK_URL=http://localhost:5000/api/auth/google/callback
ADMIN_EMAIL=admin@saviored.com
ADMIN_PASSWORD=admin123
FRONTEND_URL=http://localhost:3000
```

3. **Start MongoDB**
```bash
# Windows
mongod

# Mac/Linux
sudo systemctl start mongod
```

4. **Create Admin User**
```bash
npm run create-admin
```

5. **Start Server**
```bash
npm run dev
```

## Testing Endpoints

### 1. Health Check
```bash
GET http://localhost:5000/health
```

### 2. Register User
```bash
POST http://localhost:5000/api/auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123",
  "name": "Test User"
}
```

### 3. Login
```bash
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123"
}
```

### 4. Get User Profile (Use token from login)
```bash
GET http://localhost:5000/api/users/profile
Authorization: Bearer YOUR_TOKEN_HERE
```

### 5. Create Focus Session
```bash
POST http://localhost:5000/api/focus-sessions
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "durationMinutes": 25
}
```

### 6. Complete Focus Session
```bash
PUT http://localhost:5000/api/focus-sessions/SESSION_ID/complete
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "totalSeconds": 1500
}
```

### 7. Get Castle
```bash
GET http://localhost:5000/api/castles/my-castle
Authorization: Bearer YOUR_TOKEN_HERE
```

### 8. Level Up Castle
```bash
PUT http://localhost:5000/api/castles/level-up
Authorization: Bearer YOUR_TOKEN_HERE
```

### 9. Get Leaderboard
```bash
GET http://localhost:5000/api/leaderboard/global
Authorization: Bearer YOUR_TOKEN_HERE
```

### 10. Get Treasure Chest
```bash
GET http://localhost:5000/api/treasure-chests/my-chest
Authorization: Bearer YOUR_TOKEN_HERE
```

## Features Implemented

✅ **Authentication**
- Email/Password registration & login
- Google OAuth login
- JWT token authentication
- Forgot password (basic implementation)
- Password reset

✅ **User Management**
- User profile CRUD
- XP (Experience Points) system
- Level calculation based on XP
- User stats tracking

✅ **Focus Sessions**
- Create focus sessions
- Track session progress
- Pause/resume functionality
- Complete sessions with rewards
- Automatic XP calculation (10 XP per minute)
- Automatic resource distribution

✅ **Castle/Level System**
- Castle creation on user registration
- Resource management (coins, stones, wood)
- Level progression with requirements
- Automatic progress calculation
- Level-up functionality

✅ **Treasure Chests**
- Automatic progress updates on session completion
- Reward badges system
- Unlock and claim functionality

✅ **Leaderboard**
- Global leaderboard
- School leaderboard (ready for filtering)
- Ranking by focus hours and level

✅ **Admin Panel**
- Admin authentication
- Dashboard statistics
- User management
- Session management
- Castle management
- Treasure chest management

## XP & Level System

- **XP Calculation**: 10 XP per minute of focused time
- **Level Formula**: `level = floor(sqrt(XP / 100)) + 1`
- **Level Progression**:
  - Level 1: 0 XP
  - Level 2: 100 XP
  - Level 3: 400 XP
  - Level 4: 900 XP
  - And so on...

## Reward System

When a focus session is completed:
- **Coins**: 1 per minute
- **Stones**: 0.5 per minute
- **Wood**: 0.3 per minute
- **XP**: 10 per minute
- **Treasure Chest Progress**: +5% per completed session

## Notes

- All endpoints require authentication except `/api/auth/*` and `/health`
- Google OAuth requires proper setup in Google Cloud Console
- Password is only required for email-based authentication
- Treasure chest progress updates automatically when sessions complete
- Level is calculated automatically based on XP

