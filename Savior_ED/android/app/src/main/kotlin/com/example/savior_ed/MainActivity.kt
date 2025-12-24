package com.example.savior_ed

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.savior.ed/app_lock"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startAppLock" -> {
                    startAppLockService()
                    result.success(true)
                }
                "stopAppLock" -> {
                    stopAppLockService()
                    result.success(true)
                }
                "checkUsageStatsPermission" -> {
                    val hasPermission = checkUsageStatsPermission()
                    result.success(hasPermission)
                }
                "requestUsageStatsPermission" -> {
                    requestUsageStatsPermission()
                    result.success(true)
                }
                "checkOverlayPermission" -> {
                    val hasPermission = checkOverlayPermission()
                    result.success(hasPermission)
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(true)
                }
                "showTimerOverlay" -> {
                    showTimerOverlay()
                    result.success(true)
                }
                "hideTimerOverlay" -> {
                    hideTimerOverlay()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Check if we were brought to front due to focus lost or overlay action
        // Use post to ensure Flutter engine is ready
        val overlayAction = intent?.getStringExtra("overlay_action")
        if (overlayAction != null) {
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                try {
                    methodChannel?.invokeMethod("onOverlayAction", overlayAction)
                } catch (e: Exception) {
                    android.util.Log.e("MainActivity", "Error calling onOverlayAction: ${e.message}")
                }
            }, 500) // Small delay to ensure Flutter is ready
        } else if (intent?.getBooleanExtra("focus_lost", false) == true) {
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                try {
                    methodChannel?.invokeMethod("onFocusLost", null)
                } catch (e: Exception) {
                    android.util.Log.e("MainActivity", "Error calling onFocusLost: ${e.message}")
                }
            }, 500) // Small delay to ensure Flutter is ready
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        
        // Check if we were brought to front due to overlay action
        val overlayAction = intent.getStringExtra("overlay_action")
        if (overlayAction != null) {
            // Use post to ensure Flutter engine is ready
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                try {
                    methodChannel?.invokeMethod("onOverlayAction", overlayAction)
                } catch (e: Exception) {
                    android.util.Log.e("MainActivity", "Error calling onOverlayAction: ${e.message}")
                }
            }, 500) // Small delay to ensure Flutter is ready
        } else if (intent.getBooleanExtra("focus_lost", false)) {
            // Use post to ensure Flutter engine is ready
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                try {
                    methodChannel?.invokeMethod("onFocusLost", null)
                } catch (e: Exception) {
                    android.util.Log.e("MainActivity", "Error calling onFocusLost: ${e.message}")
                }
            }, 500) // Small delay to ensure Flutter is ready
        }
    }

    private fun startAppLockService() {
        try {
            val intent = Intent(this, AppLockService::class.java).apply {
                action = "START_MONITORING"
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            android.util.Log.d("MainActivity", "✅ App lock service start requested")
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "❌ Error starting app lock service", e)
        }
    }

    private fun stopAppLockService() {
        val intent = Intent(this, AppLockService::class.java).apply {
            action = "STOP_MONITORING"
        }
        startService(intent)
    }

    private fun checkUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        startActivity(intent)
    }

    private fun checkOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true // Permission not required on older versions
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(this)) {
                val intent = Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    android.net.Uri.parse("package:$packageName")
                )
                startActivity(intent)
            }
        }
    }

    private fun showTimerOverlay() {
        try {
            val intent = Intent(this, TimerOverlayService::class.java).apply {
                action = "SHOW_TIMER"
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            android.util.Log.d("MainActivity", "✅ Timer overlay service start requested")
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "❌ Error starting timer overlay service", e)
        }
    }

    private fun hideTimerOverlay() {
        try {
            val intent = Intent(this, TimerOverlayService::class.java).apply {
                action = "HIDE_TIMER"
            }
            startService(intent)
            android.util.Log.d("MainActivity", "✅ Timer overlay service stop requested")
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "❌ Error stopping timer overlay service", e)
        }
    }
}
