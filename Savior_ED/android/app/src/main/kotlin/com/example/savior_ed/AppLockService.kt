package com.example.savior_ed

import android.app.*
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat
import android.app.ActivityManager

class AppLockService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var monitoringRunnable: Runnable? = null
    private var isMonitoring = false
    private lateinit var usageStatsManager: UsageStatsManager
    private var lastCheckedPackage: String? = null
    private var cachedLauncherPackages: Set<String> = emptySet()
    
    companion object {
        private const val TAG = "AppLockService"
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "app_lock_channel"
        private const val CHECK_INTERVAL = 10L // Check every 10ms for immediate response
        
        private val ALLOWED_PACKAGES = setOf(
            "com.android.systemui",
            "com.android.phone",
            "com.google.android.dialer",
            "com.android.incallui"
        )
        
        // Common launcher/home screen package names
        private val LAUNCHER_PACKAGES = setOf(
            "com.android.launcher",
            "com.android.launcher2",
            "com.android.launcher3",
            "com.google.android.launcher",
            "com.google.android.apps.nexuslauncher",
            "com.google.android.apps.pixel.launcher",
            "com.samsung.android.launcher",
            "com.sec.android.app.launcher",
            "com.miui.home",
            "com.mi.android.globallauncher",
            "com.huawei.android.launcher",
            "com.huawei.android.launcher.unihome",
            "com.oneplus.launcher",
            "com.oneplus.launcher2",
            "com.oppo.launcher",
            "com.coloros.launcher",
            "com.vivo.launcher",
            "com.realme.launcher",
            "com.flyme.launcher",
            "com.meizu.flyme.launcher",
            "com.nothing.launcher",
            "com.asus.launcher",
            "com.lge.launcher",
            "com.lge.launcher2",
            "com.lge.launcher3",
            "com.sony.launcher",
            "com.motorola.launcher",
            "com.motorola.launcher3",
            "com.zte.launcher",
            "com.yandex.launcher",
            "com.microsoft.launcher",
            "com.nova.launcher",
            "com.teslacoilsw.launcher",
            "com.anddoes.launcher",
            "com.actionlauncher.playstore",
            "com.lawnchair.launcher",
            "com.lawnchair.launcher.ci",
            "com.chrislacy.actionlauncher.pro",
            "com.cyanogenmod.trebuchet",
            "org.cyanogenmod.trebuchet"
        )
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "🔧 Service onCreate()")
        usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        createNotificationChannel()
        cacheLauncherPackages()
    }
    
    private fun cacheLauncherPackages() {
        try {
            val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
            }
            val resolveInfos: List<ResolveInfo> = packageManager.queryIntentActivities(
                homeIntent,
                PackageManager.MATCH_DEFAULT_ONLY
            )
            
            cachedLauncherPackages = resolveInfos.map { it.activityInfo.packageName }.toSet()
            Log.d(TAG, "📦 Cached launcher packages: $cachedLauncherPackages")
        } catch (e: Exception) {
            Log.e(TAG, "Error caching launcher packages", e)
            cachedLauncherPackages = emptySet()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "📥 onStartCommand - action: ${intent?.action}")
        when (intent?.action) {
            "START_MONITORING" -> startMonitoring()
            "STOP_MONITORING" -> stopMonitoring()
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun startMonitoring() {
        if (isMonitoring) {
            Log.d(TAG, "⚠️ Already monitoring, skipping")
            return
        }
        
        Log.d(TAG, "🚀 Starting monitoring...")
        isMonitoring = true
        startForeground(NOTIFICATION_ID, createNotification())
        Log.d(TAG, "✅ Foreground service started")
        
        monitoringRunnable = object : Runnable {
            override fun run() {
                checkForegroundApp()
                if (isMonitoring) {
                    handler.postDelayed(this, CHECK_INTERVAL)
                }
            }
        }
        handler.post(monitoringRunnable!!)
        Log.d(TAG, "🔄 Monitoring loop started (checking every ${CHECK_INTERVAL}ms)")
    }

    private fun stopMonitoring() {
        Log.d(TAG, "🛑 Stopping monitoring...")
        isMonitoring = false
        monitoringRunnable?.let { handler.removeCallbacks(it) }
        hideOverlayDialog() // Hide overlay when stopping
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
        Log.d(TAG, "✅ Monitoring stopped")
    }

    private fun checkForegroundApp() {
        try {
            val currentTime = System.currentTimeMillis()
            var switchedToPackage: String? = null
            var latestEventTime: Long = 0
            
            // For Android 14 (API 34), use a larger time window to catch app switches reliably
            // Android 14 has stricter timing, so we need to check a longer window
            val timeWindow = if (Build.VERSION.SDK_INT >= 34) {
                // Android 14+ - use 1000ms window for better detection
                1000L
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                // Android 13 - use 500ms window
                500L
            } else {
                // Older versions - use 100ms window
                100L
            }
            
            // Check recent events for app switches
            val events = usageStatsManager.queryEvents(currentTime - timeWindow, currentTime)
            val event = UsageEvents.Event()
            
            // Look for MOVE_TO_FOREGROUND events (app switches)
            while (events.hasNextEvent()) {
                events.getNextEvent(event)
                if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                    // Get the most recent event
                    if (event.timeStamp > latestEventTime) {
                        switchedToPackage = event.packageName
                        latestEventTime = event.timeStamp
                    }
                }
            }
            
            if (switchedToPackage != null) {
                Log.d(TAG, "📱 Detected app switch: $switchedToPackage (Android ${Build.VERSION.SDK_INT}, window: ${timeWindow}ms)")
            }

            // Only act if there was an app switch and it's different from last check
            switchedToPackage?.let { packageName ->
                // Reset lastCheckedPackage after a short delay to allow re-checking
                handler.postDelayed({
                    if (lastCheckedPackage == packageName) {
                        lastCheckedPackage = null
                    }
                }, 2000) // Reset after 2 seconds
                
                if (packageName == lastCheckedPackage) {
                    // Already checked this package, skip
                    return
                }
                
                lastCheckedPackage = packageName
                
                // Allow our app
                if (packageName == applicationContext.packageName) {
                    return
                }
                
                // Allow system packages
                if (ALLOWED_PACKAGES.contains(packageName)) {
                    Log.d(TAG, "✅ Allowed system app: $packageName")
                    return
                }
                
                // Check if it's a launcher/home screen - this is critical!
                if (isLauncherApp(packageName)) {
                    Log.d(TAG, "✅ Allowed home screen/launcher: $packageName")
                    return
                }
                
                // It's another app - IMMEDIATELY block it and show overlay dialog
                Log.w(TAG, "🚨 Blocked app: $packageName - Blocking immediately!")
                blockAppImmediately(packageName)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking foreground app", e)
        }
    }
    
    private fun blockAppImmediately(packageName: String) {
        Log.d(TAG, "🚨 Blocking app immediately: $packageName")
        
        // For Android 14, show overlay immediately to block all screens
        // The overlay will appear on top of everything and block all interactions
        showOverlayDialog()
        
        // Also go to home screen to minimize the blocked app
        // This ensures we're on home screen, not showing the blocked app
        try {
            val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
            }
            // Post with minimal delay to ensure overlay is shown first
            handler.postDelayed({
                startActivity(homeIntent)
                Log.d(TAG, "✅ Sent to home screen to block app")
            }, 50) // Reduced delay for faster blocking on Android 14
        } catch (e: Exception) {
            Log.e(TAG, "Error going to home screen", e)
        }
    }

    private fun isLauncherApp(packageName: String): Boolean {
        // First check: cached launcher packages (most reliable)
        if (cachedLauncherPackages.contains(packageName)) {
            Log.d(TAG, "✅ Cached launcher: $packageName")
            return true
        }
        
        // Second check: known launcher packages
        if (LAUNCHER_PACKAGES.contains(packageName)) {
            Log.d(TAG, "✅ Known launcher: $packageName")
            return true
        }
        
        // Third check: package name contains "launcher" or "home" (case insensitive)
        val lowerPackageName = packageName.lowercase()
        if (lowerPackageName.contains("launcher") || 
            lowerPackageName.contains("home") ||
            lowerPackageName.contains("trebuchet") ||
            lowerPackageName.contains("nova") ||
            lowerPackageName.contains("actionlauncher") ||
            lowerPackageName.contains("lawnchair")) {
            Log.d(TAG, "✅ Launcher by name pattern: $packageName")
            return true
        }
        
        // Fourth check: Use PackageManager to check if it handles HOME intent (runtime check)
        try {
            val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
            }
            val resolveInfos: List<ResolveInfo> = packageManager.queryIntentActivities(
                homeIntent,
                PackageManager.MATCH_DEFAULT_ONLY
            )
            
            for (resolveInfo in resolveInfos) {
                if (resolveInfo.activityInfo.packageName == packageName) {
                    Log.d(TAG, "✅ Detected as launcher via PackageManager: $packageName")
                    // Add to cache for future checks
                    cachedLauncherPackages = cachedLauncherPackages + packageName
                    return true
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking if $packageName is launcher", e)
        }
        
        // Fifth check: Check if it's the default home app
        try {
            val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
            }
            val defaultHome = packageManager.resolveActivity(homeIntent, PackageManager.MATCH_DEFAULT_ONLY)
            if (defaultHome?.activityInfo?.packageName == packageName) {
                Log.d(TAG, "✅ Default home launcher: $packageName")
                cachedLauncherPackages = cachedLauncherPackages + packageName
                return true
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking default home", e)
        }
        
        // If we can't determine it's a launcher, return false (will be blocked)
        Log.d(TAG, "❌ Not detected as launcher: $packageName")
        return false
    }

    private fun showOverlayDialog() {
        try {
            // Show overlay immediately on main thread
            handler.post {
                val intent = Intent(this, FocusLostOverlayService::class.java).apply {
                    action = "SHOW_OVERLAY"
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    startForegroundService(intent)
                } else {
                    startService(intent)
                }
                Log.d(TAG, "✅ Overlay dialog service started immediately")
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error showing overlay dialog", e)
            // Fallback: bring app to front if overlay fails
            bringAppToFront()
        }
    }
    
    private fun bringAppToFront() {
        try {
            // Bring app to front immediately on main thread
            handler.post {
                val intent = Intent(this, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                    putExtra("focus_lost", true)
                }
                startActivity(intent)
                Log.d(TAG, "✅ Brought app to front immediately")
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error bringing app to front", e)
        }
    }
    
    private fun hideOverlayDialog() {
        try {
            val intent = Intent(this, FocusLostOverlayService::class.java).apply {
                action = "HIDE_OVERLAY"
            }
            startService(intent)
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error hiding overlay dialog", e)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Focus Mode",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps focus mode active"
                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("🔒 Focus Mode Active")
            .setContentText("Other apps are blocked. Stay focused!")
            .setSmallIcon(android.R.drawable.ic_lock_idle_lock)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
}
