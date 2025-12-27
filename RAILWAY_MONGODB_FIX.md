# Railway MongoDB Connection Fix

## 🔧 **Problem Identified**

The backend was crashing with this error:
```
❌ Error connecting to MongoDB: connect ECONNREFUSED ::1:27017, connect ECONNREFUSED 127.0.0.1:27017
```

### **Root Cause:**
- Backend code was looking for `MONGODB_URI` environment variable
- Railway provides `MONGO_URL` environment variable
- Backend was falling back to `localhost:27017` which doesn't exist on Railway

---

## ✅ **Fix Applied**

### **Updated `config/database.js`:**
1. **Support both variable names:**
   ```javascript
   const mongoURI = process.env.MONGO_URL || process.env.MONGODB_URI || 'mongodb://localhost:27017/saviored';
   ```
   - First tries `MONGO_URL` (Railway)
   - Falls back to `MONGODB_URI` (local development)
   - Finally falls back to localhost (local only)

2. **Removed deprecated options:**
   - Removed `useNewUrlParser: true` (deprecated in Mongoose 4.0+)
   - Removed `useUnifiedTopology: true` (deprecated in Mongoose 4.0+)

3. **Added better logging:**
   - Shows connection attempt
   - Shows connection string (with password hidden)
   - Better error messages

---

## 🚀 **What Happens Next**

1. **Railway will automatically redeploy** (if auto-deploy is enabled)
2. **Or manually trigger deployment** in Railway dashboard
3. **Backend should now connect** to Railway's MongoDB service
4. **Check deployment logs** to verify connection

---

## ✅ **Verify the Fix**

### **Step 1: Check Railway Deployment**
1. Go to Railway dashboard
2. Check "SaviorED-Backend" service
3. Look for new deployment
4. Check deployment logs

### **Step 2: Look for Success Messages**
In deployment logs, you should see:
```
🔗 Connecting to MongoDB...
📍 Connection string: mongodb://mongo:****@mongodb.railway.internal:27017
✅ MongoDB Connected: mongodb.railway.internal
📊 Database: [database_name]
🚀 Server running on port 5000
```

### **Step 3: Test Health Endpoint**
Once deployed, test:
```
GET https://saviored-backend-production.up.railway.app/health
```

Expected response:
```json
{
  "status": "OK",
  "message": "SaviorED API is running"
}
```

---

## 📋 **Railway Environment Variables**

Make sure these are set in Railway:

| Variable | Value | Status |
|----------|-------|--------|
| `MONGO_URL` | `mongodb://mongo:...@mongodb.railway.internal:27017` | ✅ Should be auto-set by Railway |
| `PORT` | `5000` (or Railway's assigned port) | ✅ Usually auto-set |
| `NODE_ENV` | `production` | ⚠️ Check if set |
| `JWT_SECRET` | `your_secret_key` | ⚠️ Must be set |
| `FRONTEND_URL` | `*` or your domain | ⚠️ Should be set |

---

## 🔍 **If Still Not Working**

### **Check 1: Railway MongoDB Service**
1. Verify MongoDB service is running in Railway
2. Check MongoDB service logs
3. Ensure MongoDB is provisioned and active

### **Check 2: Environment Variables**
1. Go to Railway → SaviorED-Backend → Variables
2. Verify `MONGO_URL` is set
3. Check if value is correct (should be internal Railway URL)

### **Check 3: Deployment Logs**
1. Check latest deployment logs
2. Look for MongoDB connection messages
3. Check for any errors

### **Check 4: Network Connectivity**
- Railway services should automatically connect
- Internal services use `.railway.internal` domain
- External connections use public URLs

---

## 📝 **Code Changes Summary**

**File:** `config/database.js`

**Before:**
```javascript
const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/saviored';
const conn = await mongoose.connect(mongoURI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});
```

**After:**
```javascript
const mongoURI = process.env.MONGO_URL || process.env.MONGODB_URI || 'mongodb://localhost:27017/saviored';
const conn = await mongoose.connect(mongoURI);
```

---

## ✅ **Status**

- ✅ Code fixed and pushed to GitHub
- ✅ Railway will auto-deploy (or trigger manually)
- ⏳ Waiting for deployment to complete
- ⏳ Verify connection in logs

**Once Railway redeploys, your backend should be working!** 🚀

