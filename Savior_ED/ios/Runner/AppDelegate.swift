import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel?
  private var isMonitoring = false
  private var focusLostTimer: Timer?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Set up method channel
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    methodChannel = FlutterMethodChannel(
      name: "com.savior.ed/app_lock",
      binaryMessenger: controller.binaryMessenger
    )
    
    methodChannel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      self?.handleMethodCall(call: call, result: result)
    }
    
    // Request notification permission
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if let error = error {
        print("❌ Notification permission error: \(error.localizedDescription)")
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startAppLock":
      startAppLock()
      result(true)
    case "stopAppLock":
      stopAppLock()
      result(true)
    case "checkUsageStatsPermission":
      // On iOS, we don't have usage stats permission like Android
      // Return true as we can monitor app lifecycle
      result(true)
    case "requestUsageStatsPermission":
      // Not applicable on iOS
      result(true)
    case "checkOverlayPermission":
      // iOS doesn't have overlay permission like Android
      result(true)
    case "requestOverlayPermission":
      // Not applicable on iOS
      result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func startAppLock() {
    if isMonitoring {
      return
    }
    
    isMonitoring = true
    print("🔒 iOS App lock monitoring started")
    
    // Monitor app lifecycle
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appDidEnterBackground),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appWillEnterForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
  }
  
  private func stopAppLock() {
    if !isMonitoring {
      return
    }
    
    isMonitoring = false
    focusLostTimer?.invalidate()
    focusLostTimer = nil
    
    NotificationCenter.default.removeObserver(self)
    print("🛑 iOS App lock monitoring stopped")
  }
  
  @objc private func appDidEnterBackground() {
    if isMonitoring {
      print("📱 App entered background - starting focus lost timer")
      // Start a timer - if user doesn't come back quickly, they might have switched apps
      focusLostTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
        // User has been away for at least 1 second
        // This might indicate they switched apps
        self?.notifyFocusLost()
      }
    }
  }
  
  @objc private func appWillEnterForeground() {
    if isMonitoring {
      print("📱 App entering foreground")
      focusLostTimer?.invalidate()
      focusLostTimer = nil
      
      // Notify Flutter that focus might have been lost
      // We'll let Flutter decide based on its state
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
        self?.methodChannel?.invokeMethod("onFocusLost", arguments: nil)
      }
    }
  }
  
  private func notifyFocusLost() {
    print("🚨 iOS: Focus lost detected")
    // Send notification to Flutter
    methodChannel?.invokeMethod("onFocusLost", arguments: nil)
    
    // Also show a local notification
    let content = UNMutableNotificationContent()
    content.title = "🔒 Focus Mode Active"
    content.body = "Return to Savior ED to continue your focus session!"
    content.sound = .default
    
    let request = UNNotificationRequest(
      identifier: "focus_lost",
      content: content,
      trigger: nil
    )
    
    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        print("❌ Error showing notification: \(error.localizedDescription)")
      }
    }
  }
  
  deinit {
    stopAppLock()
  }
}
