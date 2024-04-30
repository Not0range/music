import UIKit
import MediaPlayer
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
    private var eventChannel: FlutterEventChannel?
    public var sink: FlutterEventSink?
    
    private var hlsHandle: HPLUGIN?
    private var currentStream: HSTREAM = 0
    
    private var startedSource: String?
    private var startedMetadata: [String: Any]?
    private var startedCover: String?
    
    private var positionTimer: Timer?
    private var eventTimer: Timer?
    
    private var initialized = false
    private var sessionStarted = false
    private var playing = false
    private var liveStream = false
    
    private var repeatMode = false
    private var position = 0.0
    private var duration = 0.0
    private var finished = false
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let mainChannel = FlutterMethodChannel(name: "com.not_orange.music/main",
                                               binaryMessenger: controller.binaryMessenger)
        mainChannel.setMethodCallHandler(handler)
        eventChannel =  FlutterEventChannel(name: "com.not_orange.music/main_events",
                                            binaryMessenger: controller.binaryMessenger)
        eventChannel?.setStreamHandler(self)

        GeneratedPluginRegistrant.register(with: self)
        
        BASS_SetConfig(DWORD(BASS_CONFIG_IOS_SESSION), DWORD(BASS_IOS_SESSION_DISABLE))
        hlsHandle = BASS_PluginLoad("basshls", 0)
//        initialized = BASS_Init(-1, 44100, 0, nil, nil) == 1

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        //TODO release other items
        positionTimer?.invalidate()
        eventTimer?.invalidate()
        if currentStream != 0 {
            BASS_StreamFree(currentStream)
        }
        if initialized {
            BASS_Free()
        }
    }
    
    func handler(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String : Any]
        do {
            switch call.method {
            case "setSource":
                if args == nil {
                    throw ArgumentError()
                }
                if currentStream != 0 {
                    BASS_ChannelFree(currentStream)
                }
                
                let url: String = args!["url"] as! String
                let metadata = args!["metadata"] as? [String : Any]
                if !initialized {
                    startedSource = url
                    startedMetadata = metadata
                } else {
                    try setSource(url, metadata: metadata)
                    if repeatMode {
                        result(BASS_ChannelFlags(currentStream, DWORD(BASS_SAMPLE_LOOP), DWORD(BASS_SAMPLE_LOOP)) != -1)
                    }
                }
                result(true)
                break
            case "play":
                if args == nil {
                    throw ArgumentError()
                }
                if !initialized {
                    initialized = BASS_Init(-1, 44100, 0, nil, nil) == 1
                    if !initialized {
                        throw BassError.bassNotInitialized
                    }
                }
                
                if currentStream != 0 {
                    BASS_ChannelFree(currentStream)
                }
                
                let url: String = args!["url"] as! String
                let metadata = args!["metadata"] as? [String : Any]
                
                try setSource(url, metadata: metadata)
                if repeatMode {
                    result(BASS_ChannelFlags(currentStream, DWORD(BASS_SAMPLE_LOOP), DWORD(BASS_SAMPLE_LOOP)) != -1)
                }
                
                startAudioSession()
                
                if BASS_ChannelStart(currentStream) == 1 {
                    setRate(1)
                    finished = false
                    playing = true
                    sink?(["type": 0, "playing": true])
                    result(true)
                } else {
                    result(false)
                }
                break
            case "pause":
                try checkStream()
                
                if BASS_ChannelPause(currentStream) == 1 {
                    setRate(0)
                    playing = false
                    sink?(["type": 0, "playing": false])
                    result(true)
                } else {
                    result(false)
                }
                break
            case "resume":
                if !initialized {
                    initialized = BASS_Init(-1, 44100, 0, nil, nil) == 1
                    if !initialized {
                        throw BassError.bassNotInitialized
                    }
                    if startedSource == nil || startedMetadata == nil {
                        result(false)
                        break
                    }
                    
                    try setSource(startedSource!, metadata: startedMetadata!)
                    if startedCover != nil {
                        setCover(startedCover!)
                    }
                    
                    if repeatMode {
                        result(BASS_ChannelFlags(currentStream, DWORD(BASS_SAMPLE_LOOP), DWORD(BASS_SAMPLE_LOOP)) != -1)
                    }
                }
                
                try checkStream()
                startAudioSession()
                
                if BASS_ChannelStart(currentStream) == 1 {
                    setRate(1)
                    finished = false
                    playing = true
                    sink?(["type": 0, "playing": true])
                    result(true)
                } else {
                    result(false)
                }
                break
            case "seek":
                try checkStream()
                
                let time = args!["position"] as! Double
                let pos = BASS_ChannelSeconds2Bytes(currentStream, time)
                if BASS_ChannelSetPosition(currentStream, pos, DWORD(BASS_POS_BYTE)) == 1 {
                    let center = MPNowPlayingInfoCenter.default()
                    var metadata = center.nowPlayingInfo
                    if metadata != nil {
                        metadata?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
                        center.nowPlayingInfo = metadata
                    }
                    result(true)
                } else {
                    result(false)
                }
                break
            case "setRepeat":
                if args == nil {
                    throw ArgumentError()
                }
                
                repeatMode = args!["repeat"] as! Bool
                if !initialized { break }
                
                try checkStream()
                if repeatMode {
                    result(BASS_ChannelFlags(currentStream, DWORD(BASS_SAMPLE_LOOP), DWORD(BASS_SAMPLE_LOOP)) != -1)
                } else {
                    result(BASS_ChannelFlags(currentStream, 0, DWORD(BASS_SAMPLE_LOOP)) != -1)
                }
                result(true)
                break
            case "setEq":
                result(true)
                break
            case "setNowPlayingCover":
                if args == nil {
                    throw ArgumentError()
                }
                if !initialized {
                    startedCover = args!["path"] as? String
                } else {
                    setCover(args!["path"] as! String)
                }
                result(true)
                break
            case "clearNowPlaying":
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
                result(true)
            case "setLiked":
                if args == nil {
                    throw ArgumentError()
                }
                let center = MPRemoteCommandCenter.shared()
                let liked = args!["bookmark"] as! Bool
                if liked {
                    center.dislikeCommand.isActive = false
                    center.likeCommand.isActive = true
                } else {
                    center.likeCommand.isActive = false
                    center.dislikeCommand.isActive = true
                }
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        } catch let error as BassError {
            switch error {
            case BassError.bassNotInitialized:
                result(FlutterError(code: "1", message: "Bass lib is not initialized", details: nil))
            case BassError.streamNotInitialized:
                result(FlutterError(code: "2", message: "Bass stream is not initialized", details: nil))
            case BassError.operationError:
                result(FlutterError(code: "3", message: "Operation finished with error", details: nil))
            }
        } catch {
            result(FlutterError(code: "-1", message: "Unknown error", details: nil))
        }
    }
    
    func checkStream() throws {
        if currentStream == 0 {
            throw BassError.streamNotInitialized
        }
    }
    
    func setSource(_ url: String, metadata: [String: Any]?) throws -> Void {
        if !initialized {
            throw BassError.bassNotInitialized
        }
        
        positionTimer?.invalidate()
        position = 0
        if currentStream != 0 {
            BASS_ChannelFree(currentStream)
        }
        
        currentStream = BASS_HLS_StreamCreateURL(url, 0, nil, nil)
        if currentStream == 0 {
            throw BassError.streamNotInitialized
        }
        
        let center = MPRemoteCommandCenter.shared()
        let len = BASS_ChannelGetLength(currentStream, DWORD(BASS_POS_BYTE))
        if len != -1 {
            liveStream = false
            center.changePlaybackPositionCommand.isEnabled = true
            duration = BASS_ChannelBytes2Seconds(currentStream, len)
            
            positionTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60, repeats: true) {[unowned self] timer in
                let pos = BASS_ChannelGetPosition(currentStream, DWORD(BASS_POS_BYTE))
                position = BASS_ChannelBytes2Seconds(currentStream, pos)
                if position >= duration && !repeatMode && !finished {
                    finished = true
                    BASS_ChannelPause(currentStream)
                    BASS_ChannelSetPosition(currentStream, 0, DWORD(BASS_POS_BYTE))
                    sink?(["type": 3])
                }
            }
        } else {
            liveStream = true
            center.changePlaybackPositionCommand.isEnabled = false
            duration = -1
        }
        sink?(["type": 2, "duration": duration])
        
        eventTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 2, repeats: true) {[unowned self] _ in
            if !playing { return }
            
            let pos = liveStream ? -1 : position
            sink?(["type": 1, "position": pos])
        }
        
        if metadata == nil { return }
        let nowPlaying = [
            MPMediaItemPropertyArtist: metadata!["artist"]!,
            MPMediaItemPropertyTitle: metadata!["title"]!,
            MPMediaItemPropertyPlaybackDuration: metadata!["duration"]!,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: metadata!["position"] ?? 0,
            MPNowPlayingInfoPropertyPlaybackRate: 0,
            MPNowPlayingInfoPropertyDefaultPlaybackRate: 1.0,
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue,
            MPNowPlayingInfoPropertyIsLiveStream: metadata!["isLive"] ?? false
        ] as [String : Any]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlaying
    }
    
    func startAudioSession() {
        if sessionStarted { return }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            sessionStarted = true
        } catch {}
        initCommands()
    }
    
    func startTimer() {
        positionTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60, repeats: true) {[unowned self] timer in
            let pos = BASS_ChannelGetPosition(currentStream, DWORD(BASS_POS_BYTE))
            position = BASS_ChannelBytes2Seconds(currentStream, pos)
            
            if position >= duration && !repeatMode {
                timer.invalidate()
                sink?(["type": 3])
                BASS_ChannelSetPosition(currentStream, 0, DWORD(BASS_POS_BYTE))
            }
        }
    }
    
    func setRate(_ rate: Double) {
        let center = MPNowPlayingInfoCenter.default()
        guard var metadata = center.nowPlayingInfo else { return }
        metadata[MPNowPlayingInfoPropertyElapsedPlaybackTime] = position
        metadata[MPNowPlayingInfoPropertyPlaybackRate] = rate
        center.nowPlayingInfo = metadata
    }
    
    func setCover(_ path: String) {
        let center = MPNowPlayingInfoCenter.default()
        var metadata = center.nowPlayingInfo
        
        if metadata != nil {
            guard let image = UIImage(contentsOfFile: path) else { return }
            metadata![MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            metadata![MPNowPlayingInfoPropertyElapsedPlaybackTime] = position
            center.nowPlayingInfo = metadata
        }
    }
    
    func initCommands() {
        let center = MPRemoteCommandCenter.shared()
        center.likeCommand.addTarget {[unowned self] cmd in
            sink?(["type": 4, "cmd": "bookmark"])
            return .success
        }
        center.likeCommand.isActive = false
        center.dislikeCommand.addTarget {[unowned self] cmd in
            sink?(["type": 4, "cmd": "bookmark"])
            return .success
        }
        center.dislikeCommand.isActive = false
        center.playCommand.addTarget {[unowned self] emd in
            if playing { return .success }
            do {
                try play()
                return .success
            } catch {
                return .noActionableNowPlayingItem
            }
        }
        center.pauseCommand.addTarget {[unowned self] cmd in
            if !playing { return .success }
            do {
                try pause()
                return .success
            } catch {
                return .noActionableNowPlayingItem
            }
        }
        center.togglePlayPauseCommand.addTarget {[unowned self] cmd in
            do {
                if playing {
                    try pause()
                } else {
                    try play()
                }
                return .success
            } catch {
                return .noActionableNowPlayingItem
            }
        }
        center.nextTrackCommand.addTarget {[unowned self] cmd in
            sink?(["type": 4, "cmd": "next"])
            return .success
        }
        center.previousTrackCommand.addTarget {[unowned self] cmd in
            sink?(["type": 4, "cmd": "prev"])
            return .success
        }
        center.changePlaybackPositionCommand.addTarget {[unowned self] cmd in
            if currentStream == 0 { return .commandFailed }
            guard let e = cmd as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            
            let pos = BASS_ChannelSeconds2Bytes(currentStream, e.positionTime)
            if BASS_ChannelSetPosition(currentStream, pos, DWORD(BASS_POS_BYTE)) == 0 { return .commandFailed }
            
            position = e.positionTime
            sink?(["type": 1, "position": position])
            return .success
        }
    }
    
    func play() throws {
        try checkStream()
        if BASS_ChannelStart(currentStream) == 1 {
            finished = false
            playing = true
            sink?(["type": 0, "playing": true])
            return
        }
        throw BassError.operationError
    }
    
    func pause() throws {
        try checkStream()
        if BASS_ChannelPause(currentStream) == 1 {
            playing = false
            sink?(["type": 0, "playing": false])
            return
        }
        throw BassError.operationError
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
}

enum BassError: Error {
    case bassNotInitialized
    case streamNotInitialized
    case operationError
}

class ArgumentError: Error {}
