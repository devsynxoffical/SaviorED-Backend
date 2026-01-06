# Google Sign-In Error 10 Fix

## Issue
`ApiException: 10` (DEVELOPER_ERROR) even though Google Cloud Console is configured correctly.

## Root Cause
The `google-services.json` file shows `"oauth_client": []` (empty array), meaning the OAuth client isn't linked in the Firebase configuration.

## Solutions

### Solution 1: Regenerate google-services.json (Recommended)

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project: `saviored-c90a4`
3. Go to **Project Settings** (gear icon)
4. Scroll to **Your apps** section
5. Find your Android app (`com.example.savior_ed`)
6. Click **Download google-services.json** again
7. Replace the file at: `Savior_ED/android/app/google-services.json`
8. **Important**: Make sure the OAuth client is linked in Firebase Console

### Solution 2: Link OAuth Client in Firebase

1. In Firebase Console → Project Settings
2. Scroll to **Your apps** → Android app
3. Make sure the OAuth client ID is linked
4. If not linked, you may need to:
   - Go to Google Cloud Console
   - APIs & Services → Credentials
   - Find your Android OAuth client
   - Make sure it's associated with the Firebase project

### Solution 3: Uninstall & Reinstall App

Sometimes the app caches old configuration:

1. **Uninstall** the app completely from your device
2. **Clean** the build:
   ```bash
   flutter clean
   ```
3. **Rebuild** and install:
   ```bash
   flutter run
   ```

### Solution 4: Wait for Propagation

Google's changes can take 5-10 minutes to propagate. Wait a bit and try again.

## Code Fix Applied

I've updated the code to explicitly use the client ID:
```dart
GoogleSignIn(
  scopes: ['email', 'profile'],
  clientId: AppConsts.googleClientId,
)
```

## Verification Steps

1. ✅ SHA-1 fingerprint matches in Google Cloud Console
2. ✅ Package name is `com.example.savior_ed`
3. ✅ OAuth client is created and active
4. ✅ google-services.json is in `android/app/` folder
5. ✅ OAuth client is linked in Firebase (check oauth_client array)

## Test

After applying fixes:
1. Hot restart the app (not just hot reload)
2. Try Google Sign-In again
3. If still failing, uninstall and reinstall

---

**Most likely fix**: Regenerate `google-services.json` from Firebase Console after ensuring OAuth client is properly linked.

