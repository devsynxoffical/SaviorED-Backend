# Production .env Configuration Guide

## ✅ Your .env File Has Been Created!

Your production `.env` file has been created in `Backend-Flutter/.env` with your MongoDB connection string.

---

## 📋 **Current Configuration**

Your `.env` file contains:

```env
# Server Configuration
PORT=5000
NODE_ENV=production

# MongoDB Database (YOUR CONNECTION STRING)
MONGODB_URI=mongodb://mongo:okVROIynoBsNqQXvsraUDDTKMoAHfBDa@gondola.proxy.rlwy.net:36118

# JWT Authentication
JWT_SECRET=your_super_secret_jwt_key_change_this_to_a_strong_random_string_in_production_2024
JWT_EXPIRE=7d

# Google OAuth Configuration
GOOGLE_CLIENT_ID=your_google_client_id_here
GOOGLE_CLIENT_SECRET=your_google_client_secret_here
GOOGLE_CALLBACK_URL=https://yourdomain.com/api/auth/google/callback

# Admin Account
ADMIN_EMAIL=admin@saviored.com
ADMIN_PASSWORD=ChangeThisPassword123!

# Frontend URL
FRONTEND_URL=https://yourdomain.com
```

---

## ⚠️ **REQUIRED CHANGES - DO THESE NOW:**

### 1. **Change JWT_SECRET** (CRITICAL - Do This First!)

Generate a strong random secret:

**Windows PowerShell:**
```powershell
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 64 | ForEach-Object {[char]$_})
```

**Or use online generator:**
- Visit: https://www.lastpass.com/features/password-generator
- Set length to 64 characters
- Copy the generated string

**Update in .env:**
```env
JWT_SECRET=your_generated_64_character_random_string_here
```

### 2. **Update Admin Credentials** (REQUIRED)

Change these to secure values:
```env
ADMIN_EMAIL=your_actual_admin_email@domain.com
ADMIN_PASSWORD=YourStrongSecurePassword123!
```

### 3. **Update Frontend URL** (REQUIRED)

Replace with your actual production domain:
```env
FRONTEND_URL=https://your-actual-domain.com
```

**Examples:**
- `https://saviored.com`
- `https://app.saviored.com`
- `https://saviored.vercel.app`

### 4. **Configure Google OAuth** (Optional but Recommended)

If you want Google login:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create/Select a project
3. Enable **Google+ API**
4. Go to **Credentials** → **Create Credentials** → **OAuth 2.0 Client ID**
5. Application type: **Web application**
6. Authorized redirect URIs: `https://yourdomain.com/api/auth/google/callback`
7. Copy credentials to `.env`:
   ```env
   GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com
   GOOGLE_CLIENT_SECRET=xxx
   GOOGLE_CALLBACK_URL=https://yourdomain.com/api/auth/google/callback
   ```

### 5. **Update Google Callback URL** (If using OAuth)

Must match your frontend domain:
```env
GOOGLE_CALLBACK_URL=https://your-actual-domain.com/api/auth/google/callback
```

---

## 🚀 **Quick Start After Configuration**

### 1. Test Database Connection
```bash
npm start
```

Look for:
```
✅ MongoDB Connected: gondola.proxy.rlwy.net
📊 Database: [your_database]
```

### 2. Create Admin User
```bash
npm run create-admin
```

### 3. Test Health Endpoint
```bash
# In browser or Postman
GET http://localhost:5000/health
```

Expected response:
```json
{
  "status": "OK",
  "message": "SaviorED API is running"
}
```

---

## 📊 **Environment Variables Reference**

| Variable | Status | Action Required |
|----------|--------|-----------------|
| `PORT` | ✅ Set | None (5000 is good) |
| `NODE_ENV` | ✅ Set | None (production is correct) |
| `MONGODB_URI` | ✅ Set | ✅ **Your connection string is configured!** |
| `JWT_SECRET` | ⚠️ Default | **CHANGE THIS NOW** |
| `JWT_EXPIRE` | ✅ Set | None (7d is good) |
| `GOOGLE_CLIENT_ID` | ⚠️ Placeholder | Optional - Configure if using Google OAuth |
| `GOOGLE_CLIENT_SECRET` | ⚠️ Placeholder | Optional - Configure if using Google OAuth |
| `GOOGLE_CALLBACK_URL` | ⚠️ Placeholder | Update if using Google OAuth |
| `ADMIN_EMAIL` | ⚠️ Default | **CHANGE THIS** |
| `ADMIN_PASSWORD` | ⚠️ Default | **CHANGE THIS** |
| `FRONTEND_URL` | ⚠️ Placeholder | **UPDATE THIS** |

---

## 🔒 **Security Checklist**

Before going live, ensure:

- [ ] Changed `JWT_SECRET` to a strong random 64+ character string
- [ ] Updated `ADMIN_EMAIL` to your actual email
- [ ] Updated `ADMIN_PASSWORD` to a strong password (12+ chars, mixed case, numbers, symbols)
- [ ] Updated `FRONTEND_URL` to your production domain
- [ ] Configured Google OAuth (if using)
- [ ] Updated `GOOGLE_CALLBACK_URL` (if using OAuth)
- [ ] Verified MongoDB connection works
- [ ] Created admin user: `npm run create-admin`
- [ ] Tested health endpoint
- [ ] `.env` file is NOT committed to Git (already in `.gitignore`)

---

## 🎯 **Next Steps**

1. **Edit `.env` file** and make the required changes above
2. **Start the server**: `npm start` or `npm run dev`
3. **Create admin user**: `npm run create-admin`
4. **Test the API**: Visit `http://localhost:5000/health`
5. **Deploy to production** when ready!

---

## 📝 **Example Complete .env (After Updates)**

```env
PORT=5000
NODE_ENV=production

MONGODB_URI=mongodb://mongo:okVROIynoBsNqQXvsraUDDTKMoAHfBDa@gondola.proxy.rlwy.net:36118

JWT_SECRET=K8mN2pQ5rT9vW3xZ6bC1dF4gH7jL0kM5nP8qR2sT6uV9wX3yZ7aB0cD4eF8gH2jK5
JWT_EXPIRE=7d

GOOGLE_CLIENT_ID=123456789-abcdefghijklmnop.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-abcdefghijklmnopqrstuvwxyz
GOOGLE_CALLBACK_URL=https://saviored.com/api/auth/google/callback

ADMIN_EMAIL=admin@saviored.com
ADMIN_PASSWORD=MySecurePassword123!@#

FRONTEND_URL=https://saviored.com
```

---

## 🆘 **Troubleshooting**

### MongoDB Connection Issues
- Verify your connection string is correct
- Check if MongoDB is accessible from your server
- Test connection: The server will show connection status on startup

### JWT Errors
- Ensure `JWT_SECRET` is set and not empty
- Make sure it's a strong random string (64+ characters)

### CORS Errors
- Verify `FRONTEND_URL` matches your actual frontend domain exactly
- No trailing slashes
- Include protocol (https://)

---

**Your backend is configured and ready! Just update the required values above. 🚀**

