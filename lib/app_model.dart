import 'package:flutter/material.dart';
import 'package:music/data/models/vk/profile_vk.dart';
import 'package:music/data/models/yt/profile_yt.dart';
import 'package:music/utils/service.dart';

class AppModel extends ChangeNotifier {
  AppModel({String? vkToken, String? ytToken}) {
    _vkToken = vkToken;
    _ytToken = ytToken;
  }

  String? _vkToken;
  String? get vkToken => _vkToken;
  set vkToken(String? value) {
    if (_vkToken == value) return;
    _vkToken = value;
    notifyListeners();
  }

  String? _ytToken;
  String? get ytToken => _ytToken;
  set ytToken(String? value) {
    if (_ytToken == value) return;
    _ytToken = value;
    notifyListeners();
  }

  ProfileVk? _vkProfile;
  ProfileVk? get vkProfile => _vkProfile;
  set vkProfile(ProfileVk? value) {
    if (_vkProfile == value) return;
    _vkProfile = value;
    notifyListeners();
  }

  ProfileYt? _ytProfile;
  ProfileYt? get ytProfile => _ytProfile;
  set ytProfile(ProfileYt? value) {
    if (_ytProfile == value) return;
    _ytProfile = value;
    notifyListeners();
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

  bool _repeat = false;
  bool get repeat => _repeat;
  set repeat(bool value) {
    if (_repeat == value) return;
    _repeat = value;
    notifyListeners();
  }

  bool _shuffle = false;
  bool get shuffle => _shuffle;
  set shuffle(bool value) {
    if (_shuffle == value) return;
    _shuffle = value;
    notifyListeners();
  }

  String? _id;
  String? get id => _id;
  set id(String? value) {
    if (_id == value) return;
    _id = value;
    notifyListeners();
  }

  String _title = '';
  String get title => _title;
  set title(String value) {
    if (_title == value) return;
    _title = value;
    notifyListeners();
  }

  String _artist = '';
  String get artist => _artist;
  set artist(String value) {
    if (_artist == value) return;
    _artist = value;
    notifyListeners();
  }

  String? _img = '';
  String? get img => _img;
  set img(String? value) {
    if (_img == value) return;
    _img = value;
    notifyListeners();
  }

  Service? _service;
  Service? get service => _service;
  set service(Service? value) {
    if (_service == value) return;
    _service = value;
    notifyListeners();
  }

  String _favorite = '';
  String get favorite => _favorite;
  set favorite(String value) {
    if (_favorite == value) return;
    _favorite = value;
    notifyListeners();
  }

  bool get isFavorite => _favorite.isNotEmpty && _favorite != 'restore';
}
