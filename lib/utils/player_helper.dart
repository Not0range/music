import 'dart:async';

import 'package:flutter/services.dart';
import 'package:music/utils/utils.dart';

const _channel = MethodChannel('com.not_orange.music/main');

const _events = EventChannel('com.not_orange.music/main_events');

class PlayerHelper {
  static final _instance = PlayerHelper();
  static PlayerHelper get instance => _instance;

  final _completionController = StreamController<bool>.broadcast();

  Stream<bool> get completionStream => _completionController.stream;

  final _durationController = StreamController<double>.broadcast();

  Stream<double> get durationStream => _durationController.stream;

  final _stateController = StreamController<bool>.broadcast();

  Stream<bool> get stateStream => _stateController.stream;

  final _positionController = StreamController<double>.broadcast();

  Stream<double> get positionStream => _positionController.stream;

  final _commandController = StreamController<String>.broadcast();

  Stream<String> get commandStream => _commandController.stream;

  double _position = 0;
  double _duration = 0;
  bool _playing = false;
  bool _repeatMode = false;
  String? _source;

  double get position => _position;
  double get duration => _duration;
  bool get playing => _playing;
  bool get repeatMode => _repeatMode;
  String? get source => _source;

  PlayerHelper() {
    _events.receiveBroadcastStream().listen(listener);
  }

  void listener(dynamic args) {
    switch (args['type']) {
      case 0:
        _playing = args['playing'] == true;
        _stateController.add(_playing);
        break;
      case 1:
        _position = args['position'];
        _positionController.add(_position);
        break;
      case 2:
        _duration = args['duration'];
        _durationController.add(_duration);
        break;
      case 3:
        _stateController.add(false);
        _completionController.add(true);
        break;
      case 4:
        _commandController.add(args['cmd']);
        break;
      default:
    }
  }

  Future<void> setSource(String url, [JsonMap? metadata]) async {
    if (await _channel.invokeMethod<bool>(
            'setSource', {'url': url, 'metadata': metadata}) ==
        true) {
      _source = url;
    }
  }

  Future<void> play(String url, [JsonMap? metadata]) async {
    if (await _channel
            .invokeMethod<bool>('play', {'url': url, 'metadata': metadata}) ==
        true) {
      _source = url;
    }
  }

  Future<void> pause() async {
    await _channel.invokeMethod('pause');
  }

  Future<void> resume() async {
    await _channel.invokeMethod('resume');
  }

  Future<void> seek(double seconds) async {
    await _channel.invokeMethod<bool>('seek', {'position': seconds});
  }

  Future<void> setRepeat(bool repeat) async {
    if (await _channel.invokeMethod<bool>('setRepeat', {'repeat': repeat}) ==
        true) {
      _repeatMode = repeat;
    }
  }

  Future<void> setEq() async {}

  Future<void> setMetadataCover(String path) async {
    await _channel.invokeMethod<bool>('setNowPlayingCover', {'path': path});
  }

  Future<void> clearMetadata() async {}
}
