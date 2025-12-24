# SaviorED Backend API - Complete Endpoints Reference

**Base URL**: `http://localhost:5000` (or your server URL)

**Authentication**: Most endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer YOUR_TOKEN_HERE
```

---

## 🔐 Authentication Endpoints

### 1. Register User
```http
POST /api/auth/register
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "User Name"  // Optional
}
```

**Response (201):**
```json
{
  "success": true,
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "User Name",
    "avatar": null,
    "level": 1,
    "experiencePoints": 0
  }
}
```

---

### 2. Login
```http
POST /api/auth/login
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "success": true,
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "User Name",
    "avatar": null,
    "level": 1,
    "experiencePoints": 0
  }
}
```

---

### 3. Get Current User
```http
GET /api/auth/me
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "User Name",
    "avatar": null,
    "level": 1,
    "experiencePoints": 0
  }
}
```

---

### 4. Google OAuth Login
```http
GET /api/auth/google
```

**Response:** Redirects to Google OAuth, then to:
```
{FRONTEND_URL}/auth/callback?token={jwt_token}
```

---

### 5. Forgot Password
```http
POST /api/auth/forgot-password
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "If an account exists with this email, a password reset link has been sent."
}
```

---

### 6. Reset Password
```http
POST /api/auth/reset-password
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "newpassword123",
  "token": "reset_token"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Password reset successfully"
}
```

---

### 7. Logout
```http
POST /api/auth/logout
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## 👤 User Profile Endpoints

### 8. Get User Profile
```http
GET /api/users/profile
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "User Name",
    "avatar": "https://example.com/avatar.jpg",
    "level": 5,
    "experiencePoints": 2500,
    "totalFocusHours": 25.5,
    "totalCoins": 1500,
    "totalSessions": 50,
    "completedSessions": 45
  }
}
```

---

### 9. Update User Profile
```http
PUT /api/users/profile
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Updated Name",  // Optional
  "avatar": "https://example.com/avatar.jpg"  // Optional
}
```

**Response (200):**
```json
{
  "success": true,
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "Updated Name",
    "avatar": "https://example.com/avatar.jpg"
  }
}
```

---

### 10. Get User by ID
```http
GET /api/users/{userId}
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "User Name",
    "avatar": null,
    "level": 5,
    "experiencePoints": 2500
  }
}
```

---

## ⏱️ Focus Session Endpoints

### 11. Create Focus Session
```http
POST /api/focus-sessions
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "durationMinutes": 25
}
```

**Response (201):**
```json
{
  "success": true,
  "session": {
    "id": "session_id",
    "userId": "user_id",
    "durationMinutes": 25,
    "startTime": "2024-01-01T10:00:00.000Z",
    "isRunning": true,
    "isPaused": false,
    "focusLost": false,
    "isCompleted": false,
    "totalSeconds": 0
  }
}
```

---

### 12. Get User's Focus Sessions
```http
GET /api/focus-sessions?page=1&limit=20
Authorization: Bearer {token}
```

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)

**Response (200):**
```json
{
  "success": true,
  "sessions": [
    {
      "_id": "session_id",
      "userId": "user_id",
      "durationMinutes": 25,
      "startTime": "2024-01-01T10:00:00.000Z",
      "endTime": "2024-01-01T10:25:00.000Z",
      "totalSeconds": 1500,
      "isRunning": false,
      "isPaused": false,
      "focusLost": false,
      "isCompleted": true,
      "earnedCoins": 25,
      "earnedStones": 12,
      "earnedWood": 7,
      "createdAt": "2024-01-01T10:00:00.000Z",
      "updatedAt": "2024-01-01T10:25:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 50,
    "pages": 3
  }
}
```

---

### 13. Get Focus Session by ID
```http
GET /api/focus-sessions/{sessionId}
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "session": {
    "_id": "session_id",
    "userId": "user_id",
    "durationMinutes": 25,
    "startTime": "2024-01-01T10:00:00.000Z",
    "endTime": "2024-01-01T10:25:00.000Z",
    "totalSeconds": 1500,
    "isRunning": false,
    "isPaused": false,
    "focusLost": false,
    "isCompleted": true,
    "earnedCoins": 25,
    "earnedStones": 12,
    "earnedWood": 7
  }
}
```

---

### 14. Update Focus Session
```http
PUT /api/focus-sessions/{sessionId}/update
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "totalSeconds": 1500,  // Optional
  "isPaused": false,     // Optional
  "isRunning": true,     // Optional
  "focusLost": false     // Optional
}
```

**Response (200):**
```json
{
  "success": true,
  "session": {
    "_id": "session_id",
    "totalSeconds": 1500,
    "isPaused": false,
    "isRunning": true,
    "focusLost": false
  }
}
```

---

### 15. Complete Focus Session
```http
PUT /api/focus-sessions/{sessionId}/complete
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "totalSeconds": 1500
}
```

**Response (200):**
```json
{
  "success": true,
  "session": {
    "id": "session_id",
    "userId": "user_id",
    "durationMinutes": 25,
    "totalSeconds": 1500,
    "isCompleted": true,
    "earnedCoins": 25,
    "earnedStones": 12,
    "earnedWood": 7,
    "startTime": "2024-01-01T10:00:00.000Z",
    "endTime": "2024-01-01T10:25:00.000Z"
  },
  "rewards": {
    "coins": 25,
    "stones": 12,
    "wood": 7,
    "xp": 250,
    "levelUp": {
      "newXP": 2750,
      "oldLevel": 5,
      "newLevel": 5,
      "leveledUp": false
    }
  }
}
```

**Note:** This endpoint automatically:
- Calculates and distributes rewards
- Updates user stats (sessions, hours, coins, XP)
- Updates castle resources
- Updates treasure chest progress (+5%)
- Calculates level from XP

---

## 🏰 Castle Endpoints

### 16. Get User's Castle
```http
GET /api/castles/my-castle
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "castle": {
    "id": "castle_id",
    "userId": "user_id",
    "coins": 1500,
    "stones": 750,
    "wood": 450,
    "level": 5,
    "levelName": "LEVEL 5",
    "progressPercentage": 75.5,
    "nextLevel": 6,
    "castleImage": null,
    "levelRequirements": {
      "coins": 259,
      "stones": 130,
      "wood": 78
    },
    "updatedAt": "2024-01-01T10:00:00.000Z"
  }
}
```

---

### 17. Level Up Castle
```http
PUT /api/castles/level-up
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "castle": {
    "id": "castle_id",
    "userId": "user_id",
    "coins": 1241,
    "stones": 620,
    "wood": 372,
    "level": 6,
    "levelName": "LEVEL 6",
    "progressPercentage": 0,
    "nextLevel": 7,
    "levelRequirements": {
      "coins": 311,
      "stones": 156,
      "wood": 94
    }
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Cannot level up: insufficient resources",
  "requirements": {
    "coins": 259,
    "stones": 130,
    "wood": 78
  },
  "current": {
    "coins": 100,
    "stones": 50,
    "wood": 30
  }
}
```

---

### 18. Get Castle by User ID
```http
GET /api/castles/{userId}
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "castle": {
    "id": "castle_id",
    "userId": "user_id",
    "coins": 1500,
    "stones": 750,
    "wood": 450,
    "level": 5,
    "levelName": "LEVEL 5",
    "progressPercentage": 75.5,
    "nextLevel": 6,
    "castleImage": null
  }
}
```

---

## 🏆 Leaderboard Endpoints

### 19. Get Global Leaderboard
```http
GET /api/leaderboard/global?page=1&limit=20
Authorization: Bearer {token}
```

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)

**Response (200):**
```json
{
  "success": true,
  "type": "global",
  "entries": [
    {
      "id": "user_id",
      "userId": "user_id",
      "name": "User Name",
      "level": "Level 10",
      "rank": 1,
      "coins": 5000,
      "progressHours": 100.5,
      "progressMaxHours": 100,
      "avatar": "https://example.com/avatar.jpg",
      "buttonText": "VIEW PROFILE",
      "buttonType": "view_profile"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "pages": 8
  }
}
```

---

### 20. Get School Leaderboard
```http
GET /api/leaderboard/school?page=1&limit=20
Authorization: Bearer {token}
```

**Response:** Same format as global leaderboard

---

## 💎 Treasure Chest Endpoints

### 21. Get User's Treasure Chest
```http
GET /api/treasure-chests/my-chest
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "chest": {
    "id": "chest_id",
    "userId": "user_id",
    "progressPercentage": 45,
    "isUnlocked": false,
    "isClaimed": false,
    "rewards": [
      {
        "title": "First Focus",
        "iconName": "focus",
        "colorHex": "#3b82f6",
        "isUnlocked": false,
        "unlockedAt": null
      },
      {
        "title": "Dedicated Learner",
        "iconName": "learner",
        "colorHex": "#10b981",
        "isUnlocked": false,
        "unlockedAt": null
      }
    ],
    "unlockedAt": null,
    "claimedAt": null,
    "createdAt": "2024-01-01T10:00:00.000Z",
    "updatedAt": "2024-01-01T10:00:00.000Z"
  }
}
```

---

### 22. Update Treasure Chest Progress
```http
PUT /api/treasure-chests/update-progress
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "progressPercentage": 50
}
```

**Response (200):**
```json
{
  "success": true,
  "chest": {
    "id": "chest_id",
    "userId": "user_id",
    "progressPercentage": 50,
    "isUnlocked": false,
    "isClaimed": false,
    "rewards": [...]
  }
}
```

**Note:** Progress automatically unlocks chest at 100%

---

### 23. Claim Treasure Chest
```http
PUT /api/treasure-chests/claim
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Rewards claimed successfully",
  "chest": {
    "id": "chest_id",
    "userId": "user_id",
    "progressPercentage": 100,
    "isUnlocked": true,
    "isClaimed": true,
    "rewards": [
      {
        "title": "First Focus",
        "iconName": "focus",
        "colorHex": "#3b82f6",
        "isUnlocked": true,
        "unlockedAt": "2024-01-01T10:00:00.000Z"
      }
    ],
    "claimedAt": "2024-01-01T10:00:00.000Z"
  }
}
```

---

## 🛠️ Health Check

### 24. Health Check
```http
GET /health
```

**Response (200):**
```json
{
  "status": "OK",
  "message": "SaviorED API is running"
}
```

---

## 📊 Error Responses

All endpoints return errors in this format:

**400 Bad Request:**
```json
{
  "success": false,
  "message": "Error message",
  "errors": [
    {
      "msg": "Validation error",
      "param": "email",
      "location": "body"
    }
  ]
}
```

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "Not authorized to access this route"
}
```

**404 Not Found:**
```json
{
  "success": false,
  "message": "Resource not found"
}
```

**500 Internal Server Error:**
```json
{
  "success": false,
  "message": "Server error"
}
```

---

## 🔑 Authentication Flow

1. **Register/Login** → Get JWT token
2. **Store token** in Flutter app (SharedPreferences)
3. **Include token** in all protected requests:
   ```
   Authorization: Bearer {token}
   ```
4. **Token expires** in 7 days (configurable via JWT_EXPIRE)

---

## 📝 Important Notes

1. **Base URL**: Change `http://localhost:5000` to your server URL in production
2. **CORS**: Backend is configured to accept requests from `FRONTEND_URL` in `.env`
3. **Automatic Updates**: 
   - Treasure chest progress updates automatically when sessions complete (+5% per session)
   - User level updates automatically when XP is added
   - Castle resources update automatically when sessions complete
4. **Pagination**: All list endpoints support `page` and `limit` query parameters
5. **Timestamps**: All dates are in ISO 8601 format (UTC)

---

## 🚀 Quick Integration Example (Flutter)

```dart
// 1. Register/Login
final response = await dio.post(
  'http://localhost:5000/api/auth/login',
  data: {
    'email': 'user@example.com',
    'password': 'password123',
  },
);

final token = response.data['token'];
await storageService.saveToken(token);

// 2. Use token in requests
dio.options.headers['Authorization'] = 'Bearer $token';

// 3. Get user profile
final profileResponse = await dio.get(
  'http://localhost:5000/api/users/profile',
);

// 4. Create focus session
final sessionResponse = await dio.post(
  'http://localhost:5000/api/focus-sessions',
  data: {'durationMinutes': 25},
);

// 5. Complete session
await dio.put(
  'http://localhost:5000/api/focus-sessions/${sessionId}/complete',
  data: {'totalSeconds': 1500},
);
```

---

**All endpoints are ready for Flutter integration!** 🎉

