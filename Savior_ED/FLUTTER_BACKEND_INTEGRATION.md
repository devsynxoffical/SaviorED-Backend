# Flutter App - Backend Integration Guide

## ✅ Integration Complete!

All Flutter app endpoints have been connected to the backend API.

## 📝 Changes Made

### 1. **Base URL Configuration**
- Updated `app_consts.dart`:
  ```dart
  static const String baseUrl = 'http://localhost:5000';
  ```
  **Note:** Change this to your actual server URL in production!

### 2. **Authentication (AuthViewModel)**
✅ **Connected Endpoints:**
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user
- `POST /api/auth/logout` - Logout

**Features:**
- Real API calls with error handling
- Token management
- Session restoration
- Proper error messages

### 3. **Focus Sessions (FocusTimeViewModel)**
✅ **Connected Endpoints:**
- `POST /api/focus-sessions` - Create session
- `GET /api/focus-sessions` - Get user sessions
- `GET /api/focus-sessions/:id` - Get session by ID
- `PUT /api/focus-sessions/:id/update` - Update session
- `PUT /api/focus-sessions/:id/complete` - Complete session

**Features:**
- Create and track focus sessions
- Pause/resume functionality
- Session completion with rewards
- Automatic XP and resource distribution

### 4. **Castle Grounds (CastleGroundsViewModel)**
✅ **Connected Endpoints:**
- `GET /api/castles/my-castle` - Get user's castle
- `PUT /api/castles/level-up` - Level up castle
- `GET /api/castles/:userId` - Get castle by user ID

**Features:**
- Castle resource management
- Level progression
- Progress tracking

### 5. **Treasure Chests (TreasureChestViewModel)**
✅ **Connected Endpoints:**
- `GET /api/treasure-chests/my-chest` - Get user's chest
- `PUT /api/treasure-chests/update-progress` - Update progress
- `PUT /api/treasure-chests/claim` - Claim rewards

**Features:**
- Progress tracking
- Reward management
- Automatic progress updates on session completion

### 6. **Leaderboard (LeaderboardViewModel)**
✅ **Connected Endpoints:**
- `GET /api/leaderboard/global` - Get global leaderboard
- `GET /api/leaderboard/school` - Get school leaderboard

**Features:**
- Global and school rankings
- Pagination support
- User ranking display

## 🔧 Usage Examples

### Authentication
```dart
// Login
final authViewModel = Provider.of<AuthViewModel>(context);
final success = await authViewModel.login('user@example.com', 'password123');

// Register
final success = await authViewModel.register('user@example.com', 'password123', 'User Name');

// Check auth status
await authViewModel.checkAuthStatus();

// Logout
await authViewModel.logout();
```

### Focus Sessions
```dart
final focusViewModel = Provider.of<FocusTimeViewModel>(context);

// Create session
final session = await focusViewModel.createSession(25); // 25 minutes

// Update session (pause/resume)
await focusViewModel.updateSession(
  sessionId: session!.id,
  totalSeconds: 1500,
  isPaused: true,
);

// Complete session
final rewards = await focusViewModel.completeSession(
  sessionId: session.id,
  totalSeconds: 1500,
);
// rewards contains: coins, stones, wood, xp, levelUp info
```

### Castle Management
```dart
final castleViewModel = Provider.of<CastleGroundsViewModel>(context);

// Get castle
await castleViewModel.getMyCastle();
final castle = castleViewModel.castle;

// Level up
final success = await castleViewModel.levelUp();
```

### Treasure Chest
```dart
final chestViewModel = Provider.of<TreasureChestViewModel>(context);

// Get chest
await chestViewModel.getMyChest();

// Claim rewards
await chestViewModel.claimRewards();
```

### Leaderboard
```dart
final leaderboardViewModel = Provider.of<LeaderboardViewModel>(context);

// Get global leaderboard
await leaderboardViewModel.getGlobalLeaderboard();

// Get school leaderboard
await leaderboardViewModel.getSchoolLeaderboard();
```

## ⚙️ Configuration

### 1. Update Base URL
In `Savior_ED/lib/core/consts/app_consts.dart`:
```dart
static const String baseUrl = 'http://YOUR_SERVER_IP:5000';
```

**For Android Emulator:** Use `http://10.0.2.2:5000`  
**For iOS Simulator:** Use `http://localhost:5000`  
**For Physical Device:** Use your computer's IP address (e.g., `http://192.168.1.100:5000`)

### 2. Start Backend Server
```bash
cd Backend-Flutter
npm run dev
```

### 3. Start MongoDB
```bash
mongod
```

## 🔐 Authentication Flow

1. **User registers/logs in** → Gets JWT token
2. **Token stored** in SharedPreferences
3. **Token automatically added** to all API requests via interceptor
4. **Token expires** after 7 days (configurable)

## 📊 Data Flow

### Focus Session Completion Flow:
1. User completes session → `completeSession()` called
2. Backend calculates rewards (coins, stones, wood, XP)
3. Backend updates:
   - User stats (sessions, hours, coins, XP)
   - Castle resources
   - User level (from XP)
   - Treasure chest progress (+5%)
4. Response includes all rewards and level-up info

## 🐛 Error Handling

All viewmodels include:
- Loading states (`isLoading`)
- Error messages (`errorMessage`)
- Try-catch blocks
- User-friendly error messages

## 📱 Testing

1. **Start backend:** `npm run dev` in `Backend-Flutter`
2. **Start MongoDB:** `mongod`
3. **Run Flutter app:** `flutter run`
4. **Test registration/login** in the app
5. **Test focus sessions** - create and complete a session
6. **Check castle** - resources should update automatically
7. **Check leaderboard** - should show rankings

## ✅ All Features Connected

- ✅ User Authentication (Register, Login, Logout)
- ✅ User Profile Management
- ✅ Focus Session Tracking
- ✅ Castle/Level Management
- ✅ Treasure Chest System
- ✅ Leaderboard (Global & School)
- ✅ XP and Level System
- ✅ Reward Distribution

## 🚀 Next Steps

1. **Update base URL** to your server address
2. **Test all features** in the app
3. **Handle network errors** gracefully in UI
4. **Add loading indicators** where needed
5. **Test on physical devices** (update base URL accordingly)

## 📝 Notes

- All API calls are asynchronous
- Token is automatically included in requests
- Models handle both snake_case and camelCase from backend
- Error messages are user-friendly
- Loading states are available for UI updates

**Your Flutter app is now fully connected to the backend!** 🎉

