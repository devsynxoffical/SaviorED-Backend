# Production Setup Guide

## 🔒 Production .env Configuration

Your production `.env` file has been created with your MongoDB connection string.

### ⚠️ **CRITICAL SECURITY STEPS - DO THESE NOW:**

#### 1. **Change JWT_SECRET** (REQUIRED)
Generate a strong random secret:
```bash
# On Windows (PowerShell):
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))

# On Mac/Linux:
openssl rand -base64 32
```

Replace `JWT_SECRET` in `.env` with the generated value.

#### 2. **Update Admin Credentials** (REQUIRED)
Change these in `.env`:
```env
ADMIN_EMAIL=your_admin_email@domain.com
ADMIN_PASSWORD=YourStrongPassword123!
```

#### 3. **Configure Google OAuth** (Optional but Recommended)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable **Google+ API**
4. Go to **Credentials** → **Create Credentials** → **OAuth 2.0 Client ID**
5. Application type: **Web application**
6. Authorized redirect URIs: `https://yourdomain.com/api/auth/google/callback`
7. Copy `Client ID` and `Client Secret` to `.env`

#### 4. **Update Frontend URL** (REQUIRED)
Replace in `.env`:
```env
FRONTEND_URL=https://your-actual-domain.com
```

#### 5. **Update Google Callback URL** (If using OAuth)
```env
GOOGLE_CALLBACK_URL=https://your-actual-domain.com/api/auth/google/callback
```

---

## 🚀 **Starting the Production Server**

### Option 1: Direct Start
```bash
npm start
```

### Option 2: Using PM2 (Recommended for Production)
```bash
# Install PM2 globally
npm install -g pm2

# Start the server
pm2 start server.js --name saviored-backend

# Save PM2 configuration
pm2 save

# Setup PM2 to start on system reboot
pm2 startup
```

### Option 3: Using Docker (If containerized)
```bash
docker build -t saviored-backend .
docker run -p 5000:5000 --env-file .env saviored-backend
```

---

## ✅ **Pre-Launch Checklist**

- [ ] Changed `JWT_SECRET` to a strong random string
- [ ] Updated `ADMIN_EMAIL` and `ADMIN_PASSWORD`
- [ ] Configured Google OAuth credentials (if using)
- [ ] Updated `FRONTEND_URL` to production domain
- [ ] Updated `GOOGLE_CALLBACK_URL` to production domain
- [ ] Verified MongoDB connection string is correct
- [ ] Tested database connection
- [ ] Created admin user: `npm run create-admin`
- [ ] Tested health endpoint: `GET /health`
- [ ] Configured CORS for production domain
- [ ] Set up SSL/HTTPS (if applicable)
- [ ] Configured firewall rules
- [ ] Set up monitoring/logging
- [ ] Backed up `.env` file securely

---

## 🔍 **Testing Your Production Setup**

### 1. Test Database Connection
```bash
# The server will automatically test connection on startup
npm start
```

Look for:
```
✅ MongoDB Connected: gondola.proxy.rlwy.net
📊 Database: [database_name]
```

### 2. Test Health Endpoint
```bash
curl https://yourdomain.com/health
```

Expected response:
```json
{
  "status": "OK",
  "message": "SaviorED API is running"
}
```

### 3. Test Authentication
```bash
# Register a test user
curl -X POST https://yourdomain.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123456",
    "name": "Test User"
  }'
```

### 4. Create Admin User
```bash
npm run create-admin
```

---

## 📊 **Environment Variables Reference**

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `PORT` | Yes | Server port | `5000` |
| `NODE_ENV` | Yes | Environment mode | `production` |
| `MONGODB_URI` | Yes | MongoDB connection | `mongodb://...` |
| `JWT_SECRET` | Yes | JWT signing secret | `random_string` |
| `JWT_EXPIRE` | No | Token expiration | `7d` |
| `GOOGLE_CLIENT_ID` | Optional | Google OAuth ID | `xxx.apps.googleusercontent.com` |
| `GOOGLE_CLIENT_SECRET` | Optional | Google OAuth secret | `xxx` |
| `GOOGLE_CALLBACK_URL` | Optional | OAuth callback URL | `https://...` |
| `ADMIN_EMAIL` | Yes | Admin email | `admin@domain.com` |
| `ADMIN_PASSWORD` | Yes | Admin password | `SecurePass123!` |
| `FRONTEND_URL` | Yes | Frontend domain | `https://domain.com` |

---

## 🛡️ **Security Best Practices**

1. **Never commit `.env` to Git** - Already in `.gitignore`
2. **Use strong passwords** - Minimum 12 characters, mixed case, numbers, symbols
3. **Rotate secrets regularly** - Change JWT_SECRET periodically
4. **Use HTTPS** - Always use SSL/TLS in production
5. **Limit CORS** - Only allow your frontend domain
6. **Monitor logs** - Watch for suspicious activity
7. **Keep dependencies updated** - Run `npm audit` regularly
8. **Use environment-specific configs** - Different `.env` for dev/staging/prod

---

## 🐛 **Troubleshooting**

### MongoDB Connection Issues
- Verify connection string format
- Check network/firewall rules
- Ensure MongoDB is accessible from your server
- Test connection: `mongosh "your_connection_string"`

### JWT Errors
- Ensure `JWT_SECRET` is set and not empty
- Check token expiration settings
- Verify token format in requests

### CORS Errors
- Verify `FRONTEND_URL` matches your actual frontend domain
- Check for trailing slashes
- Ensure credentials are enabled in frontend requests

### Google OAuth Issues
- Verify callback URL matches exactly
- Check Google Cloud Console credentials
- Ensure Google+ API is enabled

---

## 📞 **Support**

If you encounter issues:
1. Check server logs
2. Verify all environment variables are set
3. Test database connection
4. Review error messages in API responses

---

**Your backend is ready for production! 🚀**
