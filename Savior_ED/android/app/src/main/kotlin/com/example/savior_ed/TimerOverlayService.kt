package com.example.savior_ed

import android.app.*
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.*
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import android.view.*
import android.widget.FrameLayout
import android.widget.TextView
import android.graphics.drawable.GradientDrawable
import androidx.core.app.NotificationCompat
import java.text.SimpleDateFormat
import java.util.*
import java.util.TimeZone

class TimerOverlayService : Service() {

    private var overlayView: View? = null
    private var windowManager: WindowManager? = null
    private var timerTextView: TextView? = null

    private val handler = Handler(Looper.getMainLooper())
    private var timerRunnable: Runnable? = null
    private val prefs: SharedPreferences by lazy {
        getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    }

    companion object {
        private const val TAG = "TimerOverlay"
        private const val NOTIFICATION_ID = 1003
        private const val CHANNEL_ID = "timer_overlay_channel"
    }

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "SHOW_TIMER" -> {
                showTimerOverlay()
                startForeground(NOTIFICATION_ID, createNotification())
            }
            "HIDE_TIMER" -> {
                hideTimerOverlay()
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
        }
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun showTimerOverlay() {
        if (overlayView != null) {
            Log.d(TAG, "⚠️ Timer overlay already showing")
            return
        }

        try {
            overlayView = createTimerView()

            val windowType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            }

            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                windowType,
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                        WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED or
                        WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                        WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                PixelFormat.TRANSLUCENT
            ).apply {
                gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
                x = 0
                y = (80 * resources.displayMetrics.density).toInt() // Position below status bar
                format = PixelFormat.TRANSLUCENT
            }

            windowManager?.addView(overlayView, params)
            Log.d(TAG, "✅ Timer overlay shown")
            
            // Start timer updates
            startTimerUpdates()
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error showing timer overlay: ${e.message}", e)
        }
    }

    private fun hideTimerOverlay() {
        timerRunnable?.let { handler.removeCallbacks(it) }
        timerRunnable = null

        overlayView?.let { view ->
            try {
                windowManager?.removeView(view)
                overlayView = null
                timerTextView = null
                Log.d(TAG, "✅ Timer overlay hidden")
            } catch (e: Exception) {
                Log.e(TAG, "❌ Error hiding timer overlay: ${e.message}", e)
            }
        }
    }

    private fun createTimerView(): View {
        val dpToPx = resources.displayMetrics.density
        
        // Create container with green background (pill shape)
        val container = FrameLayout(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
            setPadding(
                (16 * dpToPx).toInt(),
                (8 * dpToPx).toInt(),
                (16 * dpToPx).toInt(),
                (8 * dpToPx).toInt()
            )
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#4CAF50")) // Green color
                cornerRadius = 20f * dpToPx // Pill shape
            }
        }

        // Timer text
        timerTextView = TextView(this).apply {
            setTextColor(Color.WHITE)
            setTextSize(android.util.TypedValue.COMPLEX_UNIT_SP, 14f)
            setTypeface(null, Typeface.BOLD)
            gravity = Gravity.CENTER
            updateTimerDisplay()
        }
        container.addView(timerTextView)

        return container
    }

    private fun startTimerUpdates() {
        timerRunnable = object : Runnable {
            override fun run() {
                updateTimerDisplay()
                // Check if timer is still running, if not hide overlay
                val isRunning = prefs.getBoolean("timer_is_running", false)
                val isPaused = prefs.getBoolean("timer_is_paused", true)
                
                if (!isRunning || isPaused) {
                    // Timer stopped or paused, hide overlay
                    hideTimerOverlay()
                    stopForeground(STOP_FOREGROUND_REMOVE)
                    stopSelf()
                } else {
                    handler.postDelayed(this, 1000) // Update every second
                }
            }
        }
        handler.post(timerRunnable!!)
    }

    private fun updateTimerDisplay() {
        timerTextView?.let { textView ->
            try {
                val totalSeconds = prefs.getInt("timer_total_seconds", -1)
                val initialDuration = prefs.getInt("timer_initial_duration", 25)
                val isRunning = prefs.getBoolean("timer_is_running", false)
                val isPaused = prefs.getBoolean("timer_is_paused", true)
                val lastSaveTimeStr = prefs.getString("timer_last_save_time", null)

                val initialTotalSeconds = initialDuration * 60
                
                if (totalSeconds >= 0 && initialDuration > 0) {
                    var remainingSeconds = totalSeconds

                    // If timer is running and not paused, calculate current remaining time
                    if (isRunning && !isPaused && lastSaveTimeStr != null) {
                        try {
                            val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
                            dateFormat.timeZone = TimeZone.getTimeZone("UTC")
                            val lastSaveTime = dateFormat.parse(lastSaveTimeStr)
                            val now = Date()
                            val secondsSinceLastSave = ((now.time - lastSaveTime.time) / 1000).toInt()
                            remainingSeconds = (totalSeconds - secondsSinceLastSave).coerceAtLeast(0)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error parsing time: ${e.message}", e)
                        }
                    }

                    // Format as MM:SS
                    val minutes = remainingSeconds / 60
                    val seconds = remainingSeconds % 60
                    val timeString = String.format(Locale.US, "%02d:%02d", minutes, seconds)
                    textView.text = timeString
                } else {
                    textView.text = "00:00"
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error updating timer: ${e.message}", e)
                textView.text = "00:00"
            }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Timer Overlay",
                NotificationManager.IMPORTANCE_LOW
            )
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Focus Timer")
            .setContentText("Timer overlay active")
            .setSmallIcon(android.R.drawable.ic_lock_idle_lock)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    override fun onDestroy() {
        super.onDestroy()
        hideTimerOverlay()
    }
}

