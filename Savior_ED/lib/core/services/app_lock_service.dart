import 'dart:io' show Platform;
import 'package:flutter/services.dart';

/// Service to manage app lock functionality on Android and iOS
/// Communicates with native code via platform channels
class AppLockService {
  static const MethodChannel _channel = MethodChannel('com.savior.ed/app_lock');
  static final AppLockService _instance = AppLockService._internal();

  factory AppLockService() => _instance;

  AppLockService._internal() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Callback when focus is lost (user tried to switch apps)
  Function()? onFocusLost;

  /// Callback when overlay action is triggered (exit_battle or stay_focused)
  Function(String)? onOverlayAction;

  /// Handle method calls from native Android
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    print('📞 Method call received: ${call.method}');
    switch (call.method) {
      case 'onFocusLost':
        print('🚨 onFocusLost called, triggering callback');
        onFocusLost?.call();
        break;
      case 'onOverlayAction':
        final action = call.arguments as String?;
        print('🚨 onOverlayAction called with action: $action');
        if (action != null) {
          onOverlayAction?.call(action);
        }
        break;
      default:
        print('⚠️ Unknown method call: ${call.method}');
    }
  }

  /// Start app lock monitoring
  /// Returns true if successful, false otherwise
  Future<bool> startAppLock() async {
    try {
      print('🔒 Starting app lock service...');
      final result = await _channel.invokeMethod<bool>('startAppLock');
      final success = result ?? false;
      print('🔒 App lock service start result: $success');
      return success;
    } on PlatformException catch (e) {
      print('❌ Error starting app lock: ${e.message}');
      print('❌ Error details: ${e.details}');
      return false;
    } catch (e) {
      print('❌ Unexpected error starting app lock: $e');
      return false;
    }
  }

  /// Stop app lock monitoring
  /// Returns true if successful, false otherwise
  Future<bool> stopAppLock() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopAppLock');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error stopping app lock: ${e.message}');
      return false;
    }
  }

  /// Check if Usage Stats permission is granted
  /// Returns true if granted, false otherwise
  /// On iOS, always returns true as we use app lifecycle monitoring
  Future<bool> checkUsageStatsPermission() async {
    // iOS doesn't have usage stats permission, use app lifecycle instead
    if (Platform.isIOS) {
      return true;
    }
    
    try {
      final result = await _channel.invokeMethod<bool>(
        'checkUsageStatsPermission',
      );
      return result ?? false;
    } on PlatformException catch (e) {
      print('Error checking permission: ${e.message}');
      return false;
    } on MissingPluginException catch (e) {
      print('⚠️ Usage stats permission check not available: ${e.message}');
      return false;
    }
  }

  /// Request Usage Stats permission
  /// Opens system settings for user to grant permission
  /// On iOS, does nothing as permission is not needed
  Future<void> requestUsageStatsPermission() async {
    // iOS doesn't need usage stats permission
    if (Platform.isIOS) {
      return;
    }
    
    try {
      await _channel.invokeMethod('requestUsageStatsPermission');
    } on PlatformException catch (e) {
      print('Error requesting permission: ${e.message}');
    } on MissingPluginException catch (e) {
      print('⚠️ Usage stats permission request not available: ${e.message}');
    }
  }

  /// Check if Overlay (Display over other apps) permission is granted
  /// Returns true if granted, false otherwise
  /// On iOS, always returns true as overlay permission doesn't exist
  Future<bool> checkOverlayPermission() async {
    // iOS doesn't have overlay permission
    if (Platform.isIOS) {
      return true;
    }
    
    try {
      final result = await _channel.invokeMethod<bool>(
        'checkOverlayPermission',
      );
      return result ?? false;
    } on MissingPluginException catch (e) {
      print('⚠️ Overlay permission check not available (plugin not found): ${e.message}');
      // Return true as fallback - overlay permission is optional for our use case
      return true;
    } on PlatformException catch (e) {
      print('⚠️ Error checking overlay permission: ${e.message}');
      // Return true as fallback - overlay permission is optional
      return true;
    } catch (e) {
      print('⚠️ Unexpected error checking overlay permission: $e');
      // Return true as fallback
      return true;
    }
  }

  /// Request Overlay (Display over other apps) permission
  /// Opens system settings for user to grant permission
  /// On iOS, does nothing as permission doesn't exist
  /// Silently fails if method is not available (for backwards compatibility)
  Future<void> requestOverlayPermission() async {
    // iOS doesn't have overlay permission
    if (Platform.isIOS) {
      return;
    }
    
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } on MissingPluginException catch (e) {
      print('⚠️ Overlay permission request not available (plugin not found): ${e.message}');
      // Silently fail - overlay permission is optional
    } on PlatformException catch (e) {
      print('⚠️ Error requesting overlay permission: ${e.message}');
      // Silently fail
    } catch (e) {
      print('⚠️ Unexpected error requesting overlay permission: $e');
      // Silently fail
    }
  }

  /// Show timer overlay (green timer at top of screen)
  /// On iOS, does nothing
  Future<void> showTimerOverlay() async {
    if (Platform.isIOS) {
      return;
    }
    
    try {
      await _channel.invokeMethod('showTimerOverlay');
      print('✅ Timer overlay show requested');
    } on PlatformException catch (e) {
      print('❌ Error showing timer overlay: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error showing timer overlay: $e');
    }
  }

  /// Hide timer overlay
  /// On iOS, does nothing
  Future<void> hideTimerOverlay() async {
    if (Platform.isIOS) {
      return;
    }
    
    try {
      await _channel.invokeMethod('hideTimerOverlay');
      print('✅ Timer overlay hide requested');
    } on PlatformException catch (e) {
      print('❌ Error hiding timer overlay: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error hiding timer overlay: $e');
    }
  }
}
