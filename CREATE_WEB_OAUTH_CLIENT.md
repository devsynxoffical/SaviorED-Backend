# Create Web OAuth Client for ID Token Support

## Why You Need This

Currently, Google Sign-In works but returns `null` for ID token. To get the ID token (for better backend verification), you need to create a **Web OAuth client** and use it as `serverClientId`.

## Steps to Create Web OAuth Client

1. **Go to Google Cloud Console:**
   - https://console.cloud.google.com/apis/credentials?project=crafty-router-483011-k0

2. **Create OAuth Client:**
   - Click **"+ CREATE CREDENTIALS"**
   - Select **"OAuth client ID"**
   - Select **"Web application"** (NOT Android)
   - Enter a name: `SaviorED Web Client`
   - Click **"CREATE"**

3. **Copy the Client ID:**
   - You'll see a Client ID like: `529181300486-xxxxxxxxxxxx.apps.googleusercontent.com`
   - Copy this ID

4. **Add to Flutter Code:**
   - Open: `Savior_ED/lib/core/consts/app_consts.dart`
   - Add:
     ```dart
     static const String googleWebClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
     ```

5. **Update GoogleSignIn:**
   - Open: `Savior_ED/lib/core/features/authentication/viewmodels/auth_viewmodel.dart`
   - Change:
     ```dart
     final GoogleSignIn googleSignIn = GoogleSignIn(
       scopes: ['email', 'profile'],
       serverClientId: AppConsts.googleWebClientId, // Add this
     );
     ```

## Alternative: Backend Already Updated

The backend has been updated to accept `accessToken` when `idToken` is null, so Google Sign-In should work now even without the Web OAuth client.

However, for better security and token verification, creating a Web OAuth client is recommended.

---

**Current Status:** Backend now accepts access token, so Google Sign-In should work! 🎉

