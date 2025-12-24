package com.example.savior_ed

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.*
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import android.text.TextUtils
import android.view.*
import android.widget.*
import androidx.core.app.NotificationCompat
import kotlin.math.*
import android.graphics.drawable.GradientDrawable
import android.content.SharedPreferences
import java.text.SimpleDateFormat
import java.util.*
import java.util.TimeZone

class FocusLostOverlayService : Service() {

    private var overlayView: View? = null
    private var windowManager: WindowManager? = null
    private var glitterView: GlitterView? = null
    private var timerTextView: TextView? = null

    private val handler = Handler(Looper.getMainLooper())
    private var animationRunnable: Runnable? = null
    private var timerRunnable: Runnable? = null
    private val prefs: SharedPreferences by lazy {
        getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    }

    companion object {
        private const val TAG = "FocusLostOverlay"
        private const val NOTIFICATION_ID = 1002
        private const val CHANNEL_ID = "focus_overlay_channel"
    }

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "SHOW_OVERLAY" -> {
                showOverlayDialog()
                startForeground(NOTIFICATION_ID, createNotification())
            }
            "HIDE_OVERLAY" -> {
                hideOverlayDialog()
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
        }
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun showOverlayDialog() {
        if (overlayView != null) {
            Log.d(TAG, "⚠️ Overlay already showing")
            return
        }

        try {
            val layoutInflater = LayoutInflater.from(this)
            overlayView = createOverlayView(layoutInflater)

            // Android 14 (API 34) and above: TYPE_APPLICATION_OVERLAY is the correct window type
            val windowType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            }

            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.MATCH_PARENT,
                windowType,
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                        WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED or
                        WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                        WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                PixelFormat.TRANSLUCENT
            ).apply {
                gravity = Gravity.CENTER
                format = PixelFormat.TRANSLUCENT
                alpha = 0.95f
                // Ensure compatibility with Android 14 (API 34) and above
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    // Android 11+ (API 30+): Ensure proper display cutout handling
                    layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
                }
            }

            windowManager?.addView(overlayView, params)
            Log.d(TAG, "✅ Overlay dialog shown - blocking all apps")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error showing overlay: ${e.message}", e)
        }
    }

    private fun hideOverlayDialog() {
        animationRunnable?.let { handler.removeCallbacks(it) }
        animationRunnable = null
        timerRunnable?.let { handler.removeCallbacks(it) }
        timerRunnable = null
        glitterView?.stopAnimation()

        overlayView?.let { view ->
            try {
                windowManager?.removeView(view)
                overlayView = null
                glitterView = null
                timerTextView = null
                Log.d(TAG, "✅ Overlay dialog hidden")
            } catch (e: Exception) {
                Log.e(TAG, "❌ Error hiding overlay: ${e.message}", e)
            }
        }
    }

    private fun createOverlayView(inflater: LayoutInflater): View {
        val container = FrameLayout(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            isClickable = true
            isFocusable = true
            isFocusableInTouchMode = true
            setOnTouchListener { _, _ -> true }
        }

        val dpToPx = resources.displayMetrics.density
        val screenWidth = resources.displayMetrics.widthPixels

        // Background - Light green translucent overlay (like iPhone design)
        val overlayBackground = View(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            setBackgroundColor(0x80000000.toInt()) // Semi-transparent dark overlay
        }
        container.addView(overlayBackground)

        // Glitter
        glitterView = GlitterView(this)
        container.addView(glitterView)
        glitterView?.startAnimation()

        // Timer display at top center (green pill-shaped indicator)
        val timerContainer = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
                topMargin = (60 * dpToPx).toInt() // Position below status bar
            }
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

        // Green circle indicator
        val greenCircle = View(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                (8 * dpToPx).toInt(),
                (8 * dpToPx).toInt()
            ).apply {
                marginEnd = (8 * dpToPx).toInt()
            }
            setBackgroundColor(Color.parseColor("#81C784")) // Lighter green
            val shape = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#81C784"))
            }
            background = shape
        }
        timerContainer.addView(greenCircle)

        // Timer text
        timerTextView = TextView(this).apply {
            setTextColor(Color.WHITE)
            setTextSize(android.util.TypedValue.COMPLEX_UNIT_SP, 14f)
            setTypeface(null, Typeface.BOLD)
            gravity = Gravity.CENTER
            updateTimerDisplay()
        }
        timerContainer.addView(timerTextView)
        container.addView(timerContainer)

        // Start timer updates
        startTimerUpdates()

        // Load images
        val focusContainerImage = loadImageFromAssets("images/focus_container.png")
            ?: loadImageFromAssets("flutter_assets/assets/images/focus_container.png")
        val exitBattleImage = loadImageFromAssets("images/exit_battle.png")
            ?: loadImageFromAssets("flutter_assets/assets/images/exit_battle.png")
        val stayFocusImage = loadImageFromAssets("images/start_focus.png")
            ?: loadImageFromAssets("flutter_assets/assets/images/start_focus.png")
            ?: loadImageFromAssets("images/stay_focus.png")
            ?: loadImageFromAssets("flutter_assets/assets/images/stay_focus.png")

        // ---------- MAIN CENTER CONTAINER ----------
        val centerContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.CENTER
            )
        }

        // ---------- LIGHT GREEN OVERLAY CONTAINER (like iPhone design) ----------
        val overlayContainerWidth = (screenWidth * 0.90).toInt()
        val overlayContainer = FrameLayout(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                overlayContainerWidth,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
            // Use focus_container image if available, otherwise use light green gradient
            if (focusContainerImage != null) {
                val imageView = ImageView(this@FocusLostOverlayService).apply {
                    setImageBitmap(focusContainerImage)
                    scaleType = ImageView.ScaleType.FIT_CENTER
                    adjustViewBounds = true
                    val ratio = focusContainerImage.height.toFloat() / focusContainerImage.width.toFloat()
                    layoutParams = FrameLayout.LayoutParams(
                        overlayContainerWidth,
                        (overlayContainerWidth * ratio).toInt()
                    )
                }
                addView(imageView)
            } else {
                background = GradientDrawable().apply {
                    setColor(Color.parseColor("#E8F5E9")) // Light green translucent
                    cornerRadius = 30f * dpToPx
                    alpha = 230 // Semi-transparent
                }
                setPadding(
                    (32 * dpToPx).toInt(),
                    (40 * dpToPx).toInt(),
                    (32 * dpToPx).toInt(),
                    (40 * dpToPx).toInt()
                )
            }
        }

        // ---------- TEXT OVERLAY (centered in focus_container image) ----------
        val textOverlay = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            val safeWidth = (overlayContainerWidth * 0.75).toInt() // Wider container for single-line text
            layoutParams = FrameLayout.LayoutParams(
                safeWidth,
                FrameLayout.LayoutParams.MATCH_PARENT,
                Gravity.CENTER
            )
            minimumWidth = safeWidth
            setPadding(0, 0, 0, 0) // Remove horizontal padding
        }

        // Greenish transparent rounded background container for WARNING text
        val warningBackground = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            setPadding(
                (20 * dpToPx).toInt(),
                (12 * dpToPx).toInt(),
                (20 * dpToPx).toInt(),
                (12 * dpToPx).toInt()
            )
            background = GradientDrawable().apply {
                setColor(Color.argb(180, 169, 218, 162)) // #a9daa2 color (70% opacity)
                cornerRadius = 20f * dpToPx
            }
        }

        // WARNING text - BIGGEST size (like iPhone mock   up)
        val titleText = TextView(this).apply {
            text = "WARNING: FOCUS LOST!"
            setTextSize(android.util.TypedValue.COMPLEX_UNIT_SP, 21f) // Smaller, more appropriate size
            setTextColor(Color.BLACK)
            setTypeface(null, Typeface.BOLD)
            gravity = Gravity.CENTER
            letterSpacing = 0.01f
            // Removed maxLines and ellipsize to show full text
        }
        warningBackground.addView(titleText)

        // Castle message text - MIDDLE size (like iPhone mockup)
        val messageText = TextView(this).apply {
            text = "Your Castle at risk!\nStay focused to build your\nkingdom"
            setTextSize(android.util.TypedValue.COMPLEX_UNIT_SP, 18f) // Middle size
            setTextColor(Color.BLACK)
            gravity = Gravity.CENTER
            setTypeface(null, Typeface.BOLD)
            setLineSpacing(0f, 1.2f)
        }

        // Time lost text - SMALLEST size (like iPhone mockup)
        val timeLossText = TextView(this).apply {
            text = "You've lost 5 minutes of study time"
            setTextSize(android.util.TypedValue.COMPLEX_UNIT_SP, 14f) // Smallest size
            setTextColor(Color.GRAY) // Gray color like iPhone design
            gravity = Gravity.CENTER
            setTypeface(null, Typeface.NORMAL) // Not bold for smallest text
            maxLines = 1 // Ensure single line
            ellipsize = TextUtils.TruncateAt.END
        }

        textOverlay.addView(warningBackground)
        textOverlay.addView(Space(this).apply {
            layoutParams = LinearLayout.LayoutParams(0, (24 * dpToPx).toInt()) // 1+ height space after WARNING
        })
        textOverlay.addView(messageText)
        textOverlay.addView(Space(this).apply {
            layoutParams = LinearLayout.LayoutParams(0, (14 * dpToPx).toInt())
        })
        textOverlay.addView(timeLossText)

        overlayContainer.addView(textOverlay)

        // ---------- BUTTONS CONTAINER (BELOW IMAGE - like iPhone design) ----------
        val buttonsContainer = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                topMargin = (24 * dpToPx).toInt() // Space between image and buttons
            }
            setPadding(
                (20 * dpToPx).toInt(),
                (16 * dpToPx).toInt(),
                (20 * dpToPx).toInt(),
                (16 * dpToPx).toInt()
            )
        }

        exitBattleImage?.let {
            val exitButton = ImageView(this).apply {
                setImageBitmap(it)
                adjustViewBounds = true
                scaleType = ImageView.ScaleType.FIT_CENTER
                val width = (screenWidth * 0.38).toInt() // Bigger buttons
                val ratio = it.height.toFloat() / it.width.toFloat()
                val buttonHeight = (width * ratio).toInt()
                layoutParams = LinearLayout.LayoutParams(
                    width,
                    buttonHeight
                ).apply {
                    marginEnd = (12 * dpToPx).toInt()
                }
                setOnClickListener {
                    sendActionToFlutter("exit_battle")
                }
            }
            buttonsContainer.addView(exitButton)
        }

        stayFocusImage?.let {
            val stayFocusButton = ImageView(this).apply {
                setImageBitmap(it)
                adjustViewBounds = true
                scaleType = ImageView.ScaleType.FIT_CENTER
                val width = (screenWidth * 0.38).toInt() // Bigger buttons
                val ratio = it.height.toFloat() / it.width.toFloat()
                val buttonHeight = (width * ratio).toInt()
                layoutParams = LinearLayout.LayoutParams(
                    width,
                    buttonHeight
                )
                setOnClickListener {
                    sendActionToFlutter("stay_focused")
                }
            }
            buttonsContainer.addView(stayFocusButton)
        }

        // Buttons are BELOW the image container (like iPhone design)
        centerContainer.addView(overlayContainer)
        centerContainer.addView(buttonsContainer)

        container.addView(centerContainer)
        return container
    }

    private fun startTimerUpdates() {
        timerRunnable = object : Runnable {
            override fun run() {
                updateTimerDisplay()
                handler.postDelayed(this, 1000) // Update every second
            }
        }
        handler.post(timerRunnable!!)
    }

    // Helper function to safely read Int values (Flutter stores them as Long)
    private fun getIntSafe(key: String, defaultValue: Int): Int {
        return try {
            val value = prefs.all[key]
            when (value) {
                is Int -> value
                is Long -> value.toInt()
                is String -> value.toIntOrNull() ?: defaultValue
                else -> defaultValue
            }
        } catch (e: Exception) {
            defaultValue
        }
    }

    private fun updateTimerDisplay() {
        timerTextView?.let { textView ->
            try {
                // Read timer state from SharedPreferences (FlutterSharedPreferences)
                // Flutter stores keys with "flutter." prefix and integers as Long
                val totalSeconds = getIntSafe("flutter.timer_total_seconds", -1)
                val initialDuration = getIntSafe("flutter.timer_initial_duration", 25) // Default 25 minutes
                val isRunning = prefs.getBoolean("flutter.timer_is_running", false)
                val isPaused = prefs.getBoolean("flutter.timer_is_paused", true)
                val timerStartTimeStr = prefs.getString("flutter.timer_start_time", null)

                Log.d(TAG, "Timer state - totalSeconds: $totalSeconds, initialDuration: $initialDuration, isRunning: $isRunning, isPaused: $isPaused")
                Log.d(TAG, "timer_start_time: $timerStartTimeStr")

                var elapsedSeconds = 0

                // Method 1: Use timer_start_time if available (most accurate - continues counting while overlay is visible)
                if (timerStartTimeStr != null && timerStartTimeStr.isNotEmpty()) {
                    try {
                        // Try multiple date formats that Flutter might use
                        // Note: Flutter's toIso8601String() may or may not include 'Z' and timezone
                        val dateFormats = listOf(
                            Pair("yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'", true),  // With microseconds and Z (UTC)
                            Pair("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", true),      // With milliseconds and Z (UTC)
                            Pair("yyyy-MM-dd'T'HH:mm:ss'Z'", true),          // Without milliseconds, with Z (UTC)
                            Pair("yyyy-MM-dd'T'HH:mm:ss.SSSSSS", false),     // With microseconds, no Z (local time)
                            Pair("yyyy-MM-dd'T'HH:mm:ss.SSS", false),        // With milliseconds, no Z (local time)
                            Pair("yyyy-MM-dd'T'HH:mm:ss", false)             // Without milliseconds, no Z (local time)
                        )
                        
                        var startTime: Date? = null
                        var parsedFormat: String? = null
                        
                        for ((format, isUtc) in dateFormats) {
                            try {
                                val dateFormat = SimpleDateFormat(format, Locale.US)
                                if (isUtc) {
                                    dateFormat.timeZone = TimeZone.getTimeZone("UTC")
                                } else {
                                    dateFormat.timeZone = TimeZone.getDefault() // Use local timezone
                                }
                                startTime = dateFormat.parse(timerStartTimeStr)
                                parsedFormat = format
                                Log.d(TAG, "✅ Parsed date with format: $format, isUtc: $isUtc")
                                break
                            } catch (e: Exception) {
                                // Try next format
                                continue
                            }
                        }
                        
                        if (startTime != null) {
                            val now = Date()
                            val elapsedMillis = now.time - startTime.time
                            elapsedSeconds = (elapsedMillis / 1000).toInt()
                            elapsedSeconds = elapsedSeconds.coerceAtLeast(0)
                            Log.d(TAG, "✅ Using start_time - now: ${now.time}, start: ${startTime.time}, elapsedMillis: $elapsedMillis, elapsedSeconds: $elapsedSeconds (format: $parsedFormat)")
                        } else {
                            Log.e(TAG, "❌ Could not parse timer_start_time with any format: $timerStartTimeStr")
                            // Fallback to method 2
                            if (totalSeconds >= 0 && initialDuration > 0) {
                                val initialTotalSeconds = initialDuration * 60
                                val remainingSeconds = totalSeconds.coerceAtLeast(0)
                                elapsedSeconds = (initialTotalSeconds - remainingSeconds).coerceAtLeast(0)
                                Log.d(TAG, "Fallback method 1 - elapsedSeconds: $elapsedSeconds")
                            }
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "❌ Error parsing timer_start_time: ${e.message}", e)
                        // Fallback to method 2
                        if (totalSeconds >= 0 && initialDuration > 0) {
                            val initialTotalSeconds = initialDuration * 60
                            val remainingSeconds = totalSeconds.coerceAtLeast(0)
                            elapsedSeconds = (initialTotalSeconds - remainingSeconds).coerceAtLeast(0)
                            Log.d(TAG, "Fallback method 2 - elapsedSeconds: $elapsedSeconds")
                        }
                    }
                } else {
                    // Method 2: Calculate from remaining time (fallback when start_time not available)
                    if (totalSeconds >= 0 && initialDuration > 0) {
                        val initialTotalSeconds = initialDuration * 60
                        val remainingSeconds = totalSeconds.coerceAtLeast(0)
                        elapsedSeconds = (initialTotalSeconds - remainingSeconds).coerceAtLeast(0)
                        Log.d(TAG, "Using fallback method - elapsedSeconds: $elapsedSeconds, remainingSeconds: $remainingSeconds")
                    } else {
                        Log.d(TAG, "⚠️ No timer data available - totalSeconds: $totalSeconds, initialDuration: $initialDuration")
                        // Show all available keys for debugging
                        val allKeys = prefs.all
                        Log.d(TAG, "Available keys: ${allKeys.keys}")
                    }
                }

                // Format as MM:SS (showing elapsed time - counting up)
                val minutes = elapsedSeconds / 60
                val seconds = elapsedSeconds % 60
                val timeString = String.format(Locale.US, "%02d:%02d", minutes, seconds)
                textView.text = timeString
                Log.d(TAG, "📊 Displaying time: $timeString (elapsedSeconds: $elapsedSeconds)")
            } catch (e: Exception) {
                Log.e(TAG, "❌ Error updating timer: ${e.message}", e)
                e.printStackTrace()
                textView.text = "00:00"
            }
        }
    }

    private fun loadImageFromAssets(fileName: String): Bitmap? {
        return try {
            val inputStream = assets.open(fileName)
            BitmapFactory.decodeStream(inputStream)
        } catch (e: Exception) {
            Log.e(TAG, "Error loading image from assets: $fileName", e)
            null
        }
    }

    private fun sendActionToFlutter(action: String) {
        hideOverlayDialog()
        try {
            val intent = Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                putExtra("overlay_action", action)
            }
            startActivity(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Error sending action to Flutter: ${e.message}", e)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Focus Overlay",
                NotificationManager.IMPORTANCE_LOW
            )
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Focus Mode")
            .setContentText("Focus lost dialog active")
            .setSmallIcon(android.R.drawable.ic_lock_idle_lock)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    override fun onDestroy() {
        super.onDestroy()
        hideOverlayDialog()
    }
}

/// GlitterView stays untouched
class GlitterView(context: Context) : View(context) {
    private var animationValue = 0f
    private val handler = Handler(Looper.getMainLooper())
    private var isAnimating = false
    private val paint = Paint().apply {
        style = Paint.Style.FILL
        isAntiAlias = true
    }

    private val particleCount = 50
    private val particles = mutableListOf<GlitterParticle>()

    init {
        for (i in 0 until particleCount) {
            particles.add(GlitterParticle(i))
        }
    }

    fun startAnimation() {
        if (isAnimating) return
        isAnimating = true
        animateGlitter()
    }

    fun stopAnimation() {
        isAnimating = false
        handler.removeCallbacksAndMessages(null)
    }

    private fun animateGlitter() {
        if (!isAnimating) return
        animationValue += 0.02f
        if (animationValue > 1f) animationValue = 0f
        invalidate()
        handler.postDelayed({ animateGlitter() }, 16)
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        if (width == 0 || height == 0) return

        for (particle in particles) {
            val baseX = (particle.index * 137.5) % width
            val baseY = (particle.index * 197.3) % height
            val offsetX = baseX + sin(animationValue * 2 * PI + particle.index) * 20
            val offsetY = baseY + cos(animationValue * 2 * PI + particle.index) * 20
            val opacity = (0.3 + 0.7 * (sin(animationValue * 2 * PI * 2 + particle.index) * 0.5 + 0.5))
                .coerceIn(0.0, 1.0)
            val particleSize = (2 + (sin(animationValue * 3 * PI + particle.index) * 0.5 + 0.5) * 3).toFloat()

            val colorValue = particle.index % 3
            val glitterColor = when (colorValue) {
                0 -> Color.argb((opacity * 0.8 * 255).toInt(), 76, 175, 80)
                1 -> Color.argb((opacity * 0.9 * 255).toInt(), 255, 235, 59)
                else -> Color.argb((opacity * 0.7 * 255).toInt(), 255, 255, 255)
            }

            paint.color = glitterColor
            canvas.drawCircle(offsetX.toFloat(), offsetY.toFloat(), particleSize, paint)

            if (opacity > 0.5) {
                paint.style = Paint.Style.STROKE
                paint.strokeWidth = 1f
                canvas.drawLine(
                    offsetX.toFloat() - particleSize * 1.5f,
                    offsetY.toFloat(),
                    offsetX.toFloat() + particleSize * 1.5f,
                    offsetY.toFloat(),
                    paint
                )
                canvas.drawLine(
                    offsetX.toFloat(),
                    offsetY.toFloat() - particleSize * 1.5f,
                    offsetX.toFloat(),
                    offsetY.toFloat() + particleSize * 1.5f,
                    paint
                )
                paint.style = Paint.Style.FILL
            }
        }
    }

    private data class GlitterParticle(val index: Int)
}
