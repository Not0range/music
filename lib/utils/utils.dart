import 'dart:math' as math;

import 'package:flutter/material.dart';

typedef JsonMap = Map<String, dynamic>;

typedef Proc1<T> = void Function(T);

String generateRandomStr(int length) {
  return List.generate(length, (_) => _randomChar()).join();
}

String _randomChar() {
  final i = math.Random().nextInt(16);
  if (i < 10) return '$i';
  return String.fromCharCode(('a'.codeUnits.first) + i - 10);
}

abstract class IMusic {
  @protected
  MusicInfo? cacheInfo;
  MusicInfo get info;
}

abstract class IPlaylist {
  @protected
  PlaylistInfo? cacheInfo;
  PlaylistInfo get info;
}

class MusicInfo {
  final String id;
  final String artist;
  final String title;
  final String url;
  final int duration;
  final String? coverSmall;
  final String? coverBig;

  MusicInfo(this.id, this.artist, this.title, this.url, this.duration,
      this.coverSmall, this.coverBig);
}

class PlaylistInfo {
  final String id;
  final String title;
  final String cover;

  PlaylistInfo(this.id, this.title, this.cover);
}
