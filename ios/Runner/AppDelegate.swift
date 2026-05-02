import Flutter
import UIKit
import Firebase
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FirebaseApp.configure()

    // 🔥 通知許可要求
    UNUserNotificationCenter.current().delegate = self

    // 🔥 APNs登録
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 🔥 APNs TOKEN取得
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {

    Messaging.messaging().apnsToken = deviceToken

    let tokenParts = deviceToken.map {
      String(format: "%02.2hhx", $0)
    }

    let token = tokenParts.joined()

    print("🔥 APNS TOKEN:", token)
  }

  // 🔥 APNs失敗
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {

    print("❌ APNS ERROR:", error.localizedDescription)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}