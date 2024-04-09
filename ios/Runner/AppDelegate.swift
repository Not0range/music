import UIKit
import MediaPlayer
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
          let batteryChannel = FlutterMethodChannel(name: "com.not_orange.music/now_playing",
                                                    binaryMessenger: controller.binaryMessenger)
          batteryChannel.setMethodCallHandler(handler)
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func handler(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setNowPlaying":
            let args = call.arguments as! [String : Any]
            let nowPlaying = [
                MPMediaItemPropertyArtist: "artist",
                MPMediaItemPropertyTitle: "title",
                MPMediaItemPropertyMediaType: MPNowPlayingInfoMediaType.audio,
            ] as [String : Any]
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlaying
        case "resetNowPlaying":
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
