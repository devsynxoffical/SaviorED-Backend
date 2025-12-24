# SaviorED Backend API

Backend API server for the SaviorED Flutter application built with Node.js, Express, and MongoDB.

## Features

- ✅ User Authentication (Email/Password + Google OAuth)
- ✅ User Profile Management
- ✅ Focus Session Tracking
- ✅ Castle/Level Management System
- ✅ Leaderboard (Global & School)
- ✅ Treasure Chest System
- ✅ Admin Panel API

## Tech Stack

- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **MongoDB** - Database
- **Mongoose** - ODM for MongoDB
- **JWT** - Authentication tokens
- **Passport.js** - Google OAuth authentication
- **bcryptjs** - Password hashing

## Prerequisites

- Node.js 18+ and npm
- MongoDB (local or cloud instance)

## Installation

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file in the root directory:
```env
PORT=5000
NODE_ENV=development

MONGODB_URI=mongodb://localhost:27017/saviored

JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRE=7d

GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_CALLBACK_URL=http://localhost:5000/api/auth/google/callback

ADMIN_EMAIL=admin@saviored.com
ADMIN_PASSWORD=admin123

FRONTEND_URL=http://localhost:3000
```

3. Start MongoDB (if running locally):
```bash
mongod
```

4. Run the server:
```bash
# Development mode with auto-reload
npm run dev

# Production mode
npm start
```

The server will start on `http://localhost:5000`

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user (Protected)
- `GET /api/auth/google` - Google OAuth login
- `POST /api/auth/logout` - Logout (Protected)

### Users
- `GET /api/users/profile` - Get user profile (Protected)
- `PUT /api/users/profile` - Update user profile (Protected)
- `GET /api/users/:id` - Get user by ID (Protected)

### Focus Sessions
- `POST /api/focus-sessions` - Create focus session (Protected)
- `GET /api/focus-sessions` - Get user's sessions (Protected)
- `GET /api/focus-sessions/:id` - Get session by ID (Protected)
- `PUT /api/focus-sessions/:id/complete` - Complete session (Protected)
- `PUT /api/focus-sessions/:id/update` - Update session (Protected)

### Castles
- `GET /api/castles/my-castle` - Get user's castle (Protected)
- `PUT /api/castles/level-up` - Level up castle (Protected)
- `GET /api/castles/:userId` - Get castle by user ID (Protected)

### Leaderboard
- `GET /api/leaderboard/global` - Get global leaderboard (Protected)
- `GET /api/leaderboard/school` - Get school leaderboard (Protected)

### Treasure Chests
- `GET /api/treasure-chests/my-chest` - Get user's chest (Protected)
- `PUT /api/treasure-chests/update-progress` - Update progress (Protected)
- `PUT /api/treasure-chests/claim` - Claim rewards (Protected)

### Admin
- `POST /admin/login` - Admin login
- `GET /admin/profile` - Get admin profile (Admin only)
- `GET /admin/dashboard/stats` - Get dashboard stats (Admin only)
- `GET /admin/users` - Get all users (Admin only)
- `GET /admin/focus-sessions` - Get all sessions (Admin only)
- `GET /admin/castle-grounds` - Get all castles (Admin only)
- `GET /admin/treasure-chests` - Get all chests (Admin only)

## Database Models

### User
- Email, password, name, avatar
- Google OAuth support
- Role (user/admin)
- Level, stats (focus hours, coins, sessions)

### FocusSession
- User reference
- Duration, start/end times
- Status (running, paused, completed)
- Rewards (coins, stones, wood)

### Castle
- User reference
- Resources (coins, stones, wood)
- Level and progress
- Level requirements

### TreasureChest
- User reference
- Progress percentage
- Rewards (badges)
- Unlock/claim status

## Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URI: `http://localhost:5000/api/auth/google/callback`
6. Copy Client ID and Client Secret to `.env`

## Initial Admin User

Create the initial admin user using the provided script:

```bash
npm run create-admin
```

This will create an admin user with:
- Email: `admin@saviored.com` (from `.env` or default)
- Password: `admin123` (from `.env` or default)

**Important:** Change the admin password after first login!

Alternatively, you can create an admin manually:
1. Register a user normally through the API
2. Update the user in MongoDB:
```javascript
db.users.updateOne(
  { email: "admin@saviored.com" },
  { $set: { role: "admin" } }
)
```

## Development

- The server uses `nodemon` for auto-reload in development
- MongoDB connection is handled automatically
- JWT tokens expire in 7 days (configurable)

## Production Deployment

1. Set `NODE_ENV=production`
2. Use a secure `JWT_SECRET`
3. Use MongoDB Atlas or a production MongoDB instance
4. Configure CORS for your frontend domain
5. Set up environment variables securely

## License

Private - SaviorED Project

