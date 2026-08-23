import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var lightTradeStreamer: LightTradeStreamer?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "LightTradeStreamer") {
      lightTradeStreamer = LightTradeStreamer(messenger: registrar.messenger())
    }
  }

  override func applicationWillTerminate(_ application: UIApplication) {
    lightTradeStreamer?.dispose()
    lightTradeStreamer = nil
    super.applicationWillTerminate(application)
  }
}
