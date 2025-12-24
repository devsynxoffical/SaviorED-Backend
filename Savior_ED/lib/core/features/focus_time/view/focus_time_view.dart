import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savior_ed/core/widgets/timer_duration_picker.dart';
import 'package:savior_ed/core/widgets/timer_progress_bar.dart';
import '../../../consts/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../routes/app_routes.dart';
import '../../../services/storage_service.dart';
import '../../../services/app_lock_service.dart';
import '../../../widgets/permission_request_dialog.dart';

/// Focus Time View - Timer screen with state persistence
class FocusTimeView extends StatefulWidget {
  const FocusTimeView({super.key});

  @override
  State<FocusTimeView> createState() => _FocusTimeViewState();
}

class _FocusTimeViewState extends State<FocusTimeView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  int _initialDurationMinutes = 25;
  int _totalSeconds = 25 * 60;
  int _minutes = 25;
  int _seconds = 0;
  bool _isPaused = true;
  bool _isRunning = false;
  bool _focusLost = false;
  bool _isDialogShowing = false; // Prevent multiple dialogs
  Timer? _timer;
  final StorageService _storageService = StorageService();
  final AppLockService _appLockService = AppLockService();
  bool _hasUsageStatsPermission = false;
  bool _hasOverlayPermission = false;
  AnimationController? _sparkleAnimationController;
  AnimationController? _glitterAnimationController;
  bool _showSessionStart = false; // Show "Session Start" indicator

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndSetup();
    _loadTimerState();
    // Don't start glitter animation on init - only when focus starts
  }

  @override
  void dispose() {
    _timer?.cancel();
    _appLockService.stopAppLock();
    _appLockService.hideTimerOverlay();
    _appLockService.onFocusLost = null;
    _sparkleAnimationController?.dispose();
    _glitterAnimationController?.dispose();
    _saveTimerState();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only save state on lifecycle changes
    // App switching detection is handled by AppLockService
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveTimerState();
    } else if (state == AppLifecycleState.resumed) {
      // Load timer state and continue if it was running
      _loadTimerState().then((_) {
        // Recheck permissions when app resumes (user might have granted them in settings)
        _recheckPermissions();
      });
    }
  }

  /// Recheck permissions when app resumes
  Future<void> _recheckPermissions() async {
    final hasUsageStats = await _appLockService.checkUsageStatsPermission();

    bool hasOverlay = true; // Default to true
    try {
      hasOverlay = await _appLockService.checkOverlayPermission();
    } catch (e) {
      print('⚠️ Could not recheck overlay permission: $e');
    }

    if (hasUsageStats != _hasUsageStatsPermission) {
      setState(() {
        _hasUsageStatsPermission = hasUsageStats;
      });
      print('📋 Usage stats permission updated: $_hasUsageStatsPermission');
    }

    if (hasOverlay != _hasOverlayPermission) {
      setState(() {
        _hasOverlayPermission = hasOverlay;
      });
      print('📋 Overlay permission updated: $_hasOverlayPermission');
    }
  }

  double get _progress {
    if (_initialDurationMinutes == 0) return 1.0;
    return _totalSeconds / (_initialDurationMinutes * 60);
  }

  Future<void> _loadTimerState() async {
    await _storageService.ensureInitialized();

    final savedTotalSeconds = _storageService.getInt('timer_total_seconds');
    final savedIsRunning = _storageService.getBool('timer_is_running') ?? false;
    final savedIsPaused = _storageService.getBool('timer_is_paused') ?? true;
    final savedInitialDuration =
        _storageService.getInt('timer_initial_duration') ?? 25;
    final savedFocusLost = _storageService.getBool('timer_focus_lost') ?? false;
    final savedLastSaveTime = _storageService.getString('timer_last_save_time');

    if (savedTotalSeconds != null && savedLastSaveTime != null) {
      setState(() {
        _initialDurationMinutes = savedInitialDuration;
        _isRunning = savedIsRunning;
        _isPaused = savedIsPaused;
        _focusLost = savedFocusLost;

        // Calculate elapsed time since last save
        final lastSave = DateTime.parse(savedLastSaveTime);
        final now = DateTime.now();
        final elapsedSeconds = now.difference(lastSave).inSeconds;

        if (_isRunning && !_isPaused) {
          // Timer was running, subtract elapsed time
          _totalSeconds = (savedTotalSeconds - elapsedSeconds).clamp(
            0,
            _initialDurationMinutes * 60,
          );

          if (_totalSeconds > 0) {
            // Continue timer - only restart if not already running
            if (_timer == null || !_timer!.isActive) {
              _startTimer();
            } else {
              // Timer is already running, just update display and ensure glitter is running
              _startGlitterAnimation();
              _updateDisplay();
            }
          } else {
            // Timer completed while away
            _totalSeconds = 0;
            _stopTimer();
            _showCompletionDialog();
          }
        } else {
          // Timer was paused or stopped, restore saved time
          _totalSeconds = savedTotalSeconds.clamp(
            0,
            _initialDurationMinutes * 60,
          );
          _updateDisplay();
        }

        _updateDisplay();
      });
      
      // Show timer overlay if timer is running and not paused
      if (_isRunning && !_isPaused && _totalSeconds > 0) {
        await _appLockService.showTimerOverlay();
      }
    } else {
      // No saved state, use default
      await _setTimerDuration(25);
    }
  }

  Future<void> _saveTimerState() async {
    await _storageService.ensureInitialized();
    await _storageService.saveInt('timer_total_seconds', _totalSeconds);
    await _storageService.saveBool('timer_is_running', _isRunning);
    await _storageService.saveBool('timer_is_paused', _isPaused);
    await _storageService.saveInt(
      'timer_initial_duration',
      _initialDurationMinutes,
    );
    await _storageService.saveBool('timer_focus_lost', _focusLost);
    await _storageService.saveString(
      'timer_last_save_time',
      DateTime.now().toIso8601String(),
    );
  }

  /// Save timer start time (when focus actually started)
  Future<void> _saveTimerStartTime() async {
    await _storageService.ensureInitialized();
    final startTime = DateTime.now().toIso8601String();
    final saved = await _storageService.saveString(
      'timer_start_time',
      startTime,
    );
    print('⏰ Saved timer_start_time: $startTime (success: $saved)');
  }

  Future<void> _setTimerDuration(int minutes) async {
    setState(() {
      _initialDurationMinutes = minutes;
      _totalSeconds = minutes * 60;
      _isRunning = false;
      _isPaused = true;
      _updateDisplay();
    });
    // Clear start time when setting new duration
    await _storageService.ensureInitialized();
    await _storageService.remove('timer_start_time');
    await _saveTimerState();
  }

  void _updateDisplay() {
    setState(() {
      _minutes = _totalSeconds ~/ 60;
      _seconds = _totalSeconds % 60;
    });
  }

  /// Check and request permission for app lock
  Future<void> _checkPermissionAndSetup() async {
    // Check Usage Stats permission
    _hasUsageStatsPermission = await _appLockService
        .checkUsageStatsPermission();

    // Check Overlay permission (optional - won't crash if not available)
    try {
      _hasOverlayPermission = await _appLockService.checkOverlayPermission();
    } catch (e) {
      print('⚠️ Could not check overlay permission: $e');
      _hasOverlayPermission = true; // Default to true as fallback
    }

    print('📋 Usage stats permission: $_hasUsageStatsPermission');
    print('📋 Overlay permission: $_hasOverlayPermission');

    // Request Usage Stats permission if needed
    if (!_hasUsageStatsPermission && mounted) {
      // Show permission dialog on first launch
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const PermissionRequestDialog(),
        );
        // Recheck permission after dialog
        _hasUsageStatsPermission = await _appLockService
            .checkUsageStatsPermission();
        print(
          '📋 Usage stats permission after dialog: $_hasUsageStatsPermission',
        );
      }
    }

    // Request Overlay permission if needed
    if (!_hasOverlayPermission && mounted) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.sp),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10.sp),
                  ),
                  child: Icon(
                    Icons.layers,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Display Over Other Apps',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To bring you back to the app when you try to open other apps, we need permission to display over other apps.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.sp),
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why we need this:',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        '• Allows the app to bring you back when you try to open other apps',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '• Essential for focus mode to work properly',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Column(
                  children: [
                    CustomButton(
                      text: 'Grant Permission',
                      backgroundColor: AppColors.primary,
                      prefixIcon: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _appLockService.requestOverlayPermission();
                        // Recheck after a delay
                        await Future.delayed(const Duration(milliseconds: 500));
                        _hasOverlayPermission = await _appLockService
                            .checkOverlayPermission();
                        print(
                          '📋 Overlay permission after request: $_hasOverlayPermission',
                        );
                      },
                    ),
                    SizedBox(height: 1.h),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Not Now',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        // Recheck permission after dialog
        _hasOverlayPermission = await _appLockService.checkOverlayPermission();
        print('📋 Overlay permission after dialog: $_hasOverlayPermission');
      }
    }

    // Set up callback for when focus is lost (fallback - overlay should handle it)
    _appLockService.onFocusLost = () {
      print('🚨 Focus lost callback triggered!');
      print(
        '📊 State - mounted: $mounted, running: $_isRunning, paused: $_isPaused, dialog showing: $_isDialogShowing',
      );
      // Only show in-app dialog if overlay didn't work (fallback)
      if (mounted && _isRunning && !_isPaused && !_isDialogShowing) {
        print('✅ Showing focus lost dialog (fallback)');
        setState(() {
          _focusLost = true;
        });
        // Use a small delay to ensure state is updated
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _showFocusLostDialog();
          }
        });
      } else {
        print(
          '⚠️ Conditions not met - mounted: $mounted, running: $_isRunning, paused: $_isPaused, dialog showing: $_isDialogShowing',
        );
      }
    };

    // Set up callback for overlay actions
    _appLockService.onOverlayAction = (String action) {
      print('🚨 Overlay action received: $action');
      if (mounted) {
        if (action == 'exit_battle') {
          // Exit battle - stop timer and go to castle grounds
          _stopTimer();
          Navigator.pushReplacementNamed(context, AppRoutes.castleGrounds);
        } else if (action == 'stay_focused') {
          // Stay focused - just save state and continue
          _saveTimerState();
          setState(() {
            _focusLost = false;
            _isDialogShowing = false;
          });
        }
      }
    };

    print('✅ App lock callback set up');
  }

  void _startTimer() async {
    _timer?.cancel();
    _isRunning = true;
    _isPaused = false;
    
    // Save timer start time only if it doesn't exist (fresh start, not resume)
    await _storageService.ensureInitialized();
    final existingStartTime = _storageService.getString('timer_start_time');
    if (existingStartTime == null) {
      await _saveTimerStartTime();
    } else {
      print('⏰ timer_start_time already exists: $existingStartTime (not overwriting)');
    }
    // Always save state after ensuring start time is set
    await _saveTimerState();

    // Start continuous glitter animation when focus starts
    _startGlitterAnimation();

    // Show "Session Start" indicator
    setState(() {
      _showSessionStart = true;
    });

    // Hide "Session Start" after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSessionStart = false;
        });
      }
    });

    // Start app lock if permission granted
    if (_hasUsageStatsPermission) {
      final started = await _appLockService.startAppLock();
      print('🔒 App lock service started: $started');
      if (!started) {
        print('⚠️ Failed to start app lock service');
      }
    } else {
      print('⚠️ Usage stats permission not granted, app lock not started');
    }

    // Show timer overlay
    await _appLockService.showTimerOverlay();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_totalSeconds > 0) {
        setState(() {
          _totalSeconds--;
          _updateDisplay();
        });
        // Save state every 5 seconds
        if (_totalSeconds % 5 == 0) {
          await _saveTimerState();
        }
      } else {
        _stopTimer();
        await _saveTimerState();
        _showCompletionDialog();
      }
    });
  }

  void _pauseTimer() async {
    if (_isRunning) {
      setState(() {
        _isPaused = !_isPaused;
      });
      if (_isPaused) {
        _timer?.cancel();
        _appLockService.stopAppLock();
        // Stop sparkles when paused
        _sparkleAnimationController?.stop();
        // Keep glitter animation running even when paused
        await _saveTimerState();
        // Hide timer overlay when paused
        await _appLockService.hideTimerOverlay();
      } else {
        // Resume timer - show sparkles (don't update start_time, keep original to preserve elapsed time)
        _startSparkleAnimation();
        // Ensure glitter animation is running
        _startGlitterAnimation();
        if (_hasUsageStatsPermission) {
          final started = await _appLockService.startAppLock();
          print('🔒 App lock service restarted: $started');
        }
        await _saveTimerState();
        // Show timer overlay when resumed
        await _appLockService.showTimerOverlay();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          if (_totalSeconds > 0) {
            setState(() {
              _totalSeconds--;
              _updateDisplay();
            });
            // Save state every 5 seconds
            if (_totalSeconds % 5 == 0) {
              await _saveTimerState();
            }
          } else {
            _stopTimer();
            await _saveTimerState();
            _showCompletionDialog();
          }
        });
      }
    }
  }

  void _startGlitterAnimation() {
    if (_glitterAnimationController == null) {
      _glitterAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 15), // Even faster duration for more speed
        lowerBound: 0.0,
        upperBound: 1.0,
      )..repeat();
    } else {
      if (!_glitterAnimationController!.isAnimating) {
        _glitterAnimationController!.repeat();
      }
    }
  }

  void _startSparkleAnimation() {
    if (_sparkleAnimationController == null) {
      _sparkleAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      )..repeat();
    } else {
      _sparkleAnimationController!.repeat();
    }
    // Stop sparkles after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _sparkleAnimationController?.stop();
      }
    });
  }

  void _stopTimer() async {
    _timer?.cancel();
    _appLockService.stopAppLock();
    // Stop glitter animation when timer stops
    _glitterAnimationController?.stop();
    // Hide timer overlay when timer stops
    await _appLockService.hideTimerOverlay();
    // Clear start time when timer stops so next start is fresh
    await _storageService.ensureInitialized();
    await _storageService.remove('timer_start_time');
    setState(() {
      _isRunning = false;
      _isPaused = true;
      _totalSeconds = _initialDurationMinutes * 60;
      _updateDisplay();
    });
    _saveTimerState();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.sp),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.sp),
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'Session Complete!',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Great job! You\'ve completed your focus session and earned rewards!',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: CustomButton(
              text: 'Continue',
              backgroundColor: AppColors.secondary,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.castleGrounds,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFocusLostDialog() {
    if (_isDialogShowing) return; // Prevent multiple dialogs

    setState(() {
      _isDialogShowing = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent, // Transparent to show system app screen
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // 1. Transparent overlay full screen
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3), // Semi-transparent overlay
              ),
            ),
            
            // 2. Continuous glitter animation
            if (_glitterAnimationController != null)
              Positioned.fill(
                child: CustomPaint(
                  size: Size(100.w, 100.h),
                  painter: GlitterPainter(
                    animationValue: _glitterAnimationController!.value,
                  ),
                ),
              ),
            
            // 3. Focus container image with text and buttons
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Focus container image with text
                  Container(
                    constraints: BoxConstraints(maxWidth: 90.w),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Image card (focus_container.png)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.sp),
                          child: Image.asset(
                            'assets/images/focus_container.png',
                            width: 90.w,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 90.w,
                                height: 60.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9).withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(20.sp),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Text centered on the image card
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.all(5.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Title - WARNING: FOCUS LOST!
                                Text(
                                  'WARNING: FOCUS LOST!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2E7D32),
                                    letterSpacing: 0.8,
                                    shadows: [
                                      Shadow(
                                        color: Colors.white.withOpacity(0.9),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                
                                // Main message
                                Text(
                                  'Your castle is at risk!\nStay focused to build your kingdom.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: 0.3,
                                    height: 1.3,
                                    shadows: [
                                      Shadow(
                                        color: Colors.white.withOpacity(0.9),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 1.5.h),
                                
                                // Time loss indicator
                                Text(
                                  "You've lost 5 minutes of study time.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2E7D32),
                                    shadows: [
                                      Shadow(
                                        color: Colors.white.withOpacity(0.9),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  // Buttons below the image card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // EXIT BATTLE button (red)
                        Expanded(
                          child: Material(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(20.sp),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20.sp),
                              onTap: () {
                                if (!mounted) return;
                                Navigator.of(context).pop();
                                setState(() {
                                  _isDialogShowing = false;
                                  _focusLost = false;
                                });
                                _stopTimer();
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.castleGrounds,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 1.8.h,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shield_outlined,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 1.5.w),
                                    Flexible(
                                      child: Text(
                                        'EXIT BATTLE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(width: 2.w),
                        
                        // STAY FOCUSED button (yellow/orange)
                        Expanded(
                          child: Material(
                            color: AppColors.coinGold,
                            borderRadius: BorderRadius.circular(20.sp),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20.sp),
                              onTap: () {
                                if (!mounted) return;
                                Navigator.of(context).pop();
                                setState(() {
                                  _focusLost = false;
                                  _isDialogShowing = false;
                                });
                                _saveTimerState();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 1.8.h,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'STAY FOCUSED !',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 1.5.w),
                                    Icon(
                                      Icons.lightbulb_outline,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA6B57E), // Base background color
      body: Stack(
        children: [
          // 1. Background image (full screen)
          Positioned.fill(
            child: Image.asset(
              'assets/images/final_house.jpg',
              width: 70,
              height: 70,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFA6B57E),
                );
              },
            ),
          ),
          // 2. Hexagonal pattern background overlay
          
          // 3. Full screen transparent overlay (opacity 0.5)
          Positioned.fill(
            child: Container(
              color: const Color(0xFFA6B57E).withOpacity(0.5),
            ),
          ),
          // 4. Continuous glitter animation (on top of transparent overlay)
          if (_glitterAnimationController != null)
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _glitterAnimationController!,
                    builder: (context, child) {
                      return CustomPaint(
                        willChange: true,
                        painter: GlitterPainter(
                          animationValue: _glitterAnimationController!.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          // 5. Main content (counter, circle, buttons) on top of everything
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: const Color(
                0xFF95A56D,
              ), // Match castle grounds AppBar color
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.menu, // Three line menu icon at left corner
                  color: Colors.white,
                  size: 24.sp,
                ),
                onPressed: () async {
                  await _saveTimerState();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              centerTitle: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildResourceIcon(
                    Icons.monetization_on,
                    AppColors.coinGold,
                    '1280',
                  ),
                  SizedBox(width: 1.5.w),
                  _buildResourceIcon(
                    Icons.construction,
                    AppColors.stoneGray,
                    '875',
                  ),
                  SizedBox(width: 1.5.w),
                  _buildResourceIcon(Icons.forest, AppColors.woodBrown, '500'),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.access_time, // Clock/timer icon at right corner
                    color: Colors.white,
                    size: 24.sp,
                  ),
                  onPressed: () async {
                    final result = await showDialog<int>(
                      context: context,
                      builder: (context) => TimerDurationPicker(
                        initialMinutes: _initialDurationMinutes,
                      ),
                    );
                    if (result != null && result != _initialDurationMinutes) {
                      if (_isRunning) {
                        _stopTimer();
                      }
                      await _setTimerDuration(result);
                    }
                  },
                  tooltip: 'Set Timer Duration',
                ),
              ],
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1. Focus to Learn Resources Header
                        SizedBox(height: 7.5.w),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(1.5.w),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10.sp),
                              ),
                              ),

                            SizedBox(width: 1.5.w),
                            Text(
                                'FOCUS TO EARN RESOURCES!',
                                style: TextStyle(
                                fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 255, 255, 255),
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),

                        SizedBox(height: 1.5.h),

                        // 2. Session time
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.5.w,
                            vertical: 0.6.h,
                          ),
                        ),

                        SizedBox(height: 10.h),

                        // 3. Circular timer with house in center (double ring design)
                            SizedBox(
                          width: 65.w,
                          height: 65.w,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                              // Outer progress ring (thicker border)
                                  SizedBox(
                                width: 65.w,
                                height: 65.w,
                                    child: CircularProgressIndicator(
                                      value: _progress,
                                      strokeWidth: 8.sp,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.2,
                                  ),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color.fromARGB(255, 60, 231, 65), // Bright green border
                                      ),
                                    ),
                                  ),
                              // Inner progress ring (increased width, bright green)
                              SizedBox(
                                width: 58.w,
                                height: 58.w,
                                child: CircularProgressIndicator(
                                  value: _progress,
                                  strokeWidth: 16.sp, // Increased from 4.sp to 6.sp
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                   const Color.fromARGB(255, 60, 231, 65), // Bright green (same as outer, not dark)
                                  ),
                                ),
                              ),
                              // Timer text and house - centered in circle
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // House image in center
                                  SizedBox(height: 0.8.h),
                                  // Timer text - centered in circle
                                      Text(
                                        '${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                      fontSize: 28.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          letterSpacing: 0.5,
                                        ),
                                    textAlign: TextAlign.center,
                                      ),
                                  SizedBox(height: 0.3.h),
                                      // FOCUS TIME label
                                      Text(
                                        'FOCUS TIME',
                                        style: TextStyle(
                                      fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                      color: const Color.fromARGB(221, 255, 255, 255).withOpacity(0.7),
                                          letterSpacing: 0.5,
                                        ),
                                    textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                        ),

                        SizedBox(height: 6.h),

                        // 4. Single TIME LEFT progress bar
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 7.w),
                          child: TimerProgressBar(
                                label: 'TIME LEFT',
                            
                                progress: _progress,

                          ),
                        ),

                        SizedBox(height: 6.h),

                        // 5. Control buttons row
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Pause button (using pause.png image)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _isRunning ? _pauseTimer : _startTimer,
                                  borderRadius: BorderRadius.circular(35.sp),
                                  child: Container(
                                    width: 20.w,
                                    height: 20.w,
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      'assets/images/pause.png',
                                      width: 18.w,
                                      height: 18.w,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        // Fallback to original button if image not found
                                        return Container(
                                          width: 18.w,
                                          height: 18.w,
                                          decoration: BoxDecoration(
                                            color: Colors.yellow.shade600,
                                            borderRadius: BorderRadius.circular(35.sp),
                                          ),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            _isRunning && !_isPaused
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.white,
                                            size: 24.sp,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              // END SESSION button (using end.png image)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    _stopTimer();
                                    await _saveTimerState();
                                    if (mounted) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.castleGrounds,
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(35.sp),
                                  child: Container(
                                    width: 18.w,
                                    height: 18.w,
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      'assets/images/end.png',
                                      width: 13.w,
                                      height: 13.w,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        // Fallback to original button if image not found
                                        return Container(
                                          width: 18.w,
                                          height: 18.w,
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade600,
                                            borderRadius: BorderRadius.circular(35.sp),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'END',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // 6. Bottom GO TO BASE button with clock icon - more rounded
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Material(
                            color: Colors.lightBlue.shade300,
                            borderRadius: BorderRadius.circular(
                              20.sp,
                            ), // More rounded corners
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                20.sp,
                              ), // More rounded corners
                              onTap: () async {
                                await _saveTimerState();
                                if (mounted) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.castleGrounds,
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 1.5.h,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.white,
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'GO TO BASE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 1.h),
                      ],
                    ),
                  ),
                  // "Session Start" indicator at top
                  if (_showSessionStart)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20.sp),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'SESSION STARTED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceIcon(IconData icon, Color color, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18.sp),
        SizedBox(width: 0.5.w),
        Text(
          value,
          style: TextStyle(
            color: Colors.white, // White text to match app bar
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for hexagonal pattern background (same as castle grounds)
class HexagonalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF95A56D)
          .withOpacity(0.3) // Match castle grounds AppBar color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const hexSize = 40.0;
    final hexHeight = hexSize * math.sqrt(3);
    final hexWidth = hexSize * 2;

    for (
      double y = -hexHeight;
      y < size.height + hexHeight;
      y += hexHeight * 0.75
    ) {
      for (
        double x = -hexWidth;
        x < size.width + hexWidth;
        x += hexWidth * 0.75
      ) {
        final offset = (y / (hexHeight * 0.75)).floor() % 2 == 0
            ? 0.0
            : hexWidth * 0.375;
        _drawHexagon(canvas, paint, x + offset, y, hexSize);
      }
    }
  }

  void _drawHexagon(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double size,
  ) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i;
      final px = x + size * math.cos(angle);
      final py = y + size * math.sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for sparkle animation around house
class SparklePainter extends CustomPainter {
  final double animationValue;

  SparklePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    final sparkleCount = 12;

    final paint = Paint()
      ..color = Colors.yellow.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < sparkleCount; i++) {
      final angle =
          (2 * math.pi * i / sparkleCount) + (animationValue * 2 * math.pi);
      final sparkleRadius =
          radius + (20 * (0.5 + 0.5 * (animationValue * 2 % 1)));
      final x = center.dx + sparkleRadius * math.cos(angle);
      final y = center.dy + sparkleRadius * math.sin(angle);

      // Draw sparkle dot
      final opacity = 0.9 - (animationValue * 2 % 1) * 0.5;
      final dotSize = 4 + (2 * (animationValue * 2 % 1));
      canvas.drawCircle(
        Offset(x, y),
        dotSize,
        paint..color = Colors.yellow.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(SparklePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Custom painter for continuous glitter animation across the screen
/// Ultra-optimized for smooth performance
class GlitterPainter extends CustomPainter {
  final double animationValue;

  GlitterPainter({required this.animationValue});

  // More particles for more glitters
  static const int particleCount = 55;
  static const double baseXMultiplier = 137.5;
  static const double baseYMultiplier = 197.3;
  static const double movementRadius = 28.0; // Increased movement radius for even faster speed
  static const double twoPi = 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    // Pre-calculate values once
    final angle = animationValue * twoPi;
    
    // Create paint objects once and reuse
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false; // Disable anti-aliasing for better performance

    // Pre-define colors with alpha
    final greenBase = const Color.fromARGB(255, 76, 175, 80);
    final yellowBase = const Color.fromARGB(255, 255, 235, 59);
    final whiteBase = Colors.white;

    // Batch draw operations
    for (int i = 0; i < particleCount; i++) {
      // Simplified position calculation
      final baseX = (i * baseXMultiplier) % size.width;
      final baseY = (i * baseYMultiplier) % size.height;
      
      // Simplified animation - use single sine wave
      final phase = angle + i;
      final offsetX = baseX + math.sin(phase) * movementRadius;
      final offsetY = baseY + math.cos(phase) * movementRadius;
      
      // Simplified opacity - smoother fade
      final opacity = (0.4 + 0.6 * (math.sin(phase * 2) * 0.5 + 0.5)).clamp(0.0, 1.0);
      
      // Increased particle size - bigger but not too much (4.0 to 6.0)
      final particleSize = 4.0 + (math.sin(phase * 1.5) * 0.5 + 0.5) * 2.0;
      
      // Select color based on index
      final colorValue = i % 3;
      if (colorValue == 0) {
        fillPaint.color = greenBase.withOpacity(opacity * 0.7);
      } else if (colorValue == 1) {
        fillPaint.color = yellowBase.withOpacity(opacity * 0.8);
      } else {
        fillPaint.color = whiteBase.withOpacity(opacity * 0.6);
      }
      
      // Draw leaf shape for every 4th particle, circle for others
      if (i % 4 == 0) {
        // Draw tiny leaf shape
        _drawLeaf(canvas, Offset(offsetX, offsetY), particleSize, fillPaint);
      } else {
        // Draw circle
        canvas.drawCircle(Offset(offsetX, offsetY), particleSize, fillPaint);
      }
    }
  }

  // Helper method to draw a tiny leaf shape
  void _drawLeaf(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    // Create a simple leaf shape (oval with a point)
    // Start from top
    path.moveTo(center.dx, center.dy - size);
    
    // Left curve
    path.quadraticBezierTo(
      center.dx - size * 0.8,
      center.dy - size * 0.3,
      center.dx - size * 0.5,
      center.dy + size * 0.2,
    );
    
    // Bottom point
    path.lineTo(center.dx, center.dy + size);
    
    // Right curve
    path.quadraticBezierTo(
      center.dx + size * 0.5,
      center.dy + size * 0.2,
      center.dx + size * 0.8,
      center.dy - size * 0.3,
    );
    
    // Close the path
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(GlitterPainter oldDelegate) {
    // Always repaint for smooth animation (the optimization is in the paint method itself)
    return true;
  }
}
