# SaviorED Admin Panel

A comprehensive admin panel for managing the SaviorED focus/productivity application.

## Features

- **Dashboard**: Overview statistics and recent activity
- **Users Management**: View, search, edit, and delete users
- **Focus Sessions**: Monitor and manage user focus time sessions
- **Castle Grounds**: View and manage user castles and resources
- **Leaderboard**: View global and school leaderboards
- **Treasure Chests**: Manage treasure chests and rewards

## Tech Stack

- **React 19** - UI library
- **React Router DOM** - Routing
- **Axios** - HTTP client
- **Vite** - Build tool

## Getting Started

### Prerequisites

- Node.js 18+ and npm

### Installation

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file in the root directory:
```env
VITE_API_BASE_URL=https://api.example.com
VITE_DEV_MODE=true  # Set to false when connecting to real API
```

**Development Mode Login Credentials:**
- **Email:** `admin@saviored.com`
- **Password:** `admin123`

*Note: These credentials only work in development mode. For production, use your backend API credentials.*

3. Start the development server:
```bash
npm run dev
```

4. Open your browser and navigate to `http://localhost:5173`

### Building for Production

```bash
npm run build
```

The built files will be in the `dist` directory.

## Project Structure

```
Adminpanel/
├── src/
│   ├── components/       # Reusable components
│   │   ├── Layout/      # Layout components (Sidebar, Header, etc.)
│   │   └── DataTable.jsx # Data table component
│   ├── contexts/         # React contexts
│   │   └── AuthContext.jsx
│   ├── pages/           # Page components
│   │   ├── Login.jsx
│   │   ├── Dashboard.jsx
│   │   ├── Users.jsx
│   │   ├── FocusSessions.jsx
│   │   ├── CastleGrounds.jsx
│   │   ├── Leaderboard.jsx
│   │   └── TreasureChests.jsx
│   ├── services/        # API services
│   │   └── api.js
│   ├── App.jsx          # Main app component
│   └── main.jsx         # Entry point
├── public/              # Static assets
└── package.json
```

## API Integration

The admin panel expects the following API endpoints:

### Authentication
- `POST /admin/login` - Admin login
- `POST /admin/logout` - Admin logout
- `GET /admin/profile` - Get admin profile

### Users
- `GET /admin/users` - Get all users (with pagination)
- `GET /admin/users/:id` - Get user by ID
- `PUT /admin/users/:id` - Update user
- `DELETE /admin/users/:id` - Delete user
- `GET /admin/users/search` - Search users

### Focus Sessions
- `GET /admin/focus-sessions` - Get all sessions
- `GET /admin/focus-sessions/:id` - Get session by ID
- `GET /admin/focus-sessions/user/:userId` - Get user sessions
- `DELETE /admin/focus-sessions/:id` - Delete session
- `GET /admin/focus-sessions/stats` - Get statistics

### Castle Grounds
- `GET /admin/castle-grounds` - Get all castles
- `GET /admin/castle-grounds/:id` - Get castle by ID
- `GET /admin/castle-grounds/user/:userId` - Get user castle
- `PUT /admin/castle-grounds/:id` - Update castle
- `GET /admin/castle-grounds/stats` - Get statistics

### Leaderboard
- `GET /admin/leaderboard/global` - Get global leaderboard
- `GET /admin/leaderboard/school` - Get school leaderboard
- `PUT /admin/leaderboard/:id` - Update leaderboard entry
- `POST /admin/leaderboard/refresh` - Refresh leaderboard

### Treasure Chests
- `GET /admin/treasure-chests` - Get all chests
- `GET /admin/treasure-chests/:id` - Get chest by ID
- `GET /admin/treasure-chests/user/:userId` - Get user chests
- `PUT /admin/treasure-chests/:id` - Update chest
- `GET /admin/treasure-chests/stats` - Get statistics

### Dashboard
- `GET /admin/dashboard/stats` - Get dashboard statistics
- `GET /admin/dashboard/activity` - Get recent activity

## Authentication

The admin panel uses JWT tokens stored in localStorage. The token is automatically included in API requests via axios interceptors.

## Development Notes

- The app currently uses mock data when API calls fail, making it easy to develop and test the UI
- All API endpoints should return data in the format expected by the components
- The admin token should be stored in localStorage with the key `admin_token`

## License

Private - SaviorED Project
