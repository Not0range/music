import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:music/data/models/new_playlist_model.dart';

import 'service.dart';

typedef JsonMap = Map<String, dynamic>;

typedef Proc1<T> = void Function(T);

final whiteSpaceRegex = RegExp(r'^\s*$');

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
  final bool lyrics;
  final String? coverSmall;
  final String? coverBig;
  final Service type;
  final JsonMap? extra;

  MusicInfo(this.id, this.artist, this.title, this.url, this.duration,
      this.lyrics, this.coverSmall, this.coverBig, this.type,
      {this.extra});

  MusicInfo.empty()
      : id = '',
        artist = '',
        title = '',
        url = '',
        duration = 0,
        lyrics = false,
        coverSmall = null,
        coverBig = null,
        type = Service.local,
        extra = null;

  MusicInfo.vk(this.id, this.artist, this.title, this.url, this.duration,
      this.lyrics, this.coverSmall, this.coverBig,
      {this.extra})
      : type = Service.vk;

  MusicInfo.youtube(this.id, this.artist, this.title, this.url, this.duration,
      this.lyrics, this.coverSmall, this.coverBig,
      {this.extra})
      : type = Service.youtube;

  MusicInfo copyWith(
      {String? id,
      String? artist,
      String? title,
      String? url,
      int? duration,
      bool? lyrics,
      String? coverSmall,
      String? coverBig,
      JsonMap? extra}) {
    return MusicInfo(
        id ?? this.id,
        artist ?? this.artist,
        title ?? this.title,
        url ?? this.url,
        duration ?? this.duration,
        lyrics ?? this.lyrics,
        coverSmall ?? this.coverSmall,
        coverBig ?? this.coverBig,
        type,
        extra: extra ?? this.extra);
  }

  factory MusicInfo.fromJson(JsonMap json) {
    return MusicInfo(
        json['id'],
        json['artist'],
        json['title'],
        json['url'] ?? '',
        json['duration'],
        json['lyrics'] ?? false,
        json['coverSmall'],
        json['coverBig'],
        Service.values[json['type']],
        extra: jsonDecode(json['extra']));
  }

  JsonMap toJson() {
    return {
      'id': id,
      'artist': artist,
      'title': title,
      'duration': duration,
      'coverSmall': coverSmall,
      'coverBig': coverBig,
      'type': type.index,
      'extra': jsonEncode(extra)
    };
  }
}

class PlaylistInfo {
  final String id;
  final String title;
  final String cover;
  final PrivacyType privacy;
  final Service type;

  PlaylistInfo(this.id, this.title, this.cover, this.privacy, this.type);

  PlaylistInfo.vk(this.id, this.title, this.cover, this.privacy)
      : type = Service.vk;

  PlaylistInfo.youtube(this.id, this.title, this.cover, this.privacy)
      : type = Service.youtube;
}

enum PlaylistStartMode { replace, add, headQueue, tailQueue }

class BroadcastCommand {
  final BroadcastCommandType type;
  final Service service;
  final JsonMap? params;

  BroadcastCommand(this.type, this.service, [this.params]);
}

enum BroadcastCommandType {
  changeFavorites,
  followPlaylist,
  addToPlaylist,
  needUrl,
}

enum ChangePlayableType { list, queue, shuffled, trackIndex }
