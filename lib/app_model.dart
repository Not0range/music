import 'package:flutter/material.dart';
import 'package:music/data/models/vk/profile_vk.dart';
import 'package:music/data/models/yt/profile_yt.dart';

class AppModel extends ChangeNotifier {
  AppModel({String? vkToken, String? ytToken}) {
    _vkToken = vkToken;
    _ytToken = ytToken;
  }

  String? _vkToken;
  String? get vkToken => _vkToken;
  set vkToken(String? value) {
    _vkToken = value;
    notifyListeners();
  }

  String? _ytToken;
  String? get ytToken => _ytToken;
  set ytToken(String? value) {
    _ytToken = value;
    notifyListeners();
  }

  ProfileVk? _vkProfile;
  ProfileVk? get vkProfile => _vkProfile;
  set vkProfile(ProfileVk? value) {
    if (_vkProfile == value) return;
    _vkProfile = value;
  }

  ProfileYt? _ytProfile;
  ProfileYt? get ytProfile => _ytProfile;
  set ytProfile(ProfileYt? value) {
    if (_ytProfile == value) return;
    _ytProfile = value;
  }
}

class PlayerModel extends ChangeNotifier {
  Duration _duration = Duration.zero;
  Duration get duration => _duration;
  set duration(Duration value) {
    if (_duration == value) return;
    _duration = value;
    notifyListeners();
  }

  Duration _position = Duration.zero;
  Duration get position => _position;
  set position(Duration value) {
    if (_position == value) return;
    _position = value;
    notifyListeners();
  }

  bool _playing = false;
  bool get playing => _playing;
  set playing(bool value) {
    if (_playing == value) return;
    _playing = value;
    notifyListeners();
  }

  String _title = '';
  String get title => _title;
  set title(String value) {
    _title = value;
    notifyListeners();
  }

  String _artist = '';
  String get artist => _artist;
  set artist(String value) {
    _artist = value;
    notifyListeners();
  }

  String _img = '';
  String get img => _img;
  set img(String value) {
    _img = value;
    notifyListeners();
  }
}
