import UIKit
import Flutter
import flutter_downloader
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerDownloaderPlugins)
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback(registerNotificationPlugin)

    if #availeble(iOS 10.0, *){
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenter
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private func registerDownloaderPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}

private func registerNotificationPlugin(registry: FlutterPluginRegistry){
if (!registry.hasPlugin("FlutterLocalNotificationsPlugin")) {
       FlutterLocalNotificationsPlugin.register(with: registry.registrar(forPlugin: "FlutterLocalNotificationsPlugin")!)
    }
}