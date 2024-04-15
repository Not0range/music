import 'package:flutter/material.dart';
import 'package:music/data/models/vk/playlist_vk.dart';
import 'package:music/data/models/vk/profile_vk.dart';
import 'package:music/data/models/yt/profile_yt.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/utils.dart';

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

  String _lyrics = '';
  String get lyrics => _lyrics;
  set lyrics(String value) {
    _lyrics = value;
    notifyListeners();
  }

  int? _index;
  int? get index => _index;
  set index(int? value) {
    if (_index == value) return;

    _index = value;
    notifyListeners();
  }

  List<MusicInfo> _list = [];
  List<MusicInfo> get list => _list;
  set list(List<MusicInfo> value) {
    if (_list == value) return;

    _list = value;
    _shuffled = null;
    _index = 0;
    notifyListeners();
  }

  List<MusicInfo>? _shuffled;
  List<MusicInfo>? get shuffled => _shuffled;

  set shuffle(bool value) {
    if (value) {
      _shuffled = _list.toList();

      MusicInfo? current;
      if (_queue.isEmpty) current = _shuffled!.removeAt(_index!);
      _shuffled!.shuffle();

      if (current != null) _shuffled!.insert(0, current);
      _index = 0;
    } else if (_shuffled != null) {
      _index = _list.indexOf(_shuffled![_index!]);
      _shuffled = null;
    }
    notifyListeners();
  }

  List<MusicInfo> _queue = [];
  List<MusicInfo> get queue => _queue;
  set queue(List<MusicInfo> value) {
    if (_list == value) return;

    _queue = value;
    notifyListeners();
  }

  void setItem(MusicInfo item,
      {String? id,
      Service? type,
      String? favorite,
      String? artist,
      String? title,
      String? img}) {
    _id = id ?? item.id;
    _service = type ?? item.type;
    _favorite = favorite ?? '';

    _artist = artist ?? item.artist;
    _title = title ?? item.title;
    _img = img ?? item.coverBig;
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (_index == null) return;

    if (oldIndex < newIndex) newIndex -= 1;

    final list = _shuffled ?? _list;
    final current = list[_index!];

    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    _index = list.indexOf(current);
    notifyListeners();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (_index == null) return;

    if (oldIndex < newIndex) newIndex -= 1;

    final item = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, item);

    notifyListeners();
  }

  bool _fromQueue = false;
  bool get fromQueue => _fromQueue;
  set fromQueue(bool value) {
    if (_fromQueue == value) return;
    _fromQueue = value;
    notifyListeners();
  }

  ///Ставит трек в начало очереди \
  ///Возвращается true при пустом списке воспроизведения
  ///предполагается выбор указанного трека как текущего
  bool headQueue(MusicInfo item) {
    if (_index == null) {
      _id = item.id;
      _service = item.type;
      _favorite = '${item.extra?['favorite'] ?? ''}';

      _artist = item.artist;
      _title = item.title;
      _img = item.coverBig;
      notifyListeners();
      return true;
    }
    _queue.insert(0, item);
    notifyListeners();
    return false;
  }

  ///Ставит трек в конец очереди \
  ///Возвращается true при пустом списке воспроизведения
  ///предполагается выбор указанного трека как текущего
  bool tailQueue(MusicInfo item) {
    if (_index == null) {
      _id = item.id;
      _service = item.type;
      _favorite = '${item.extra?['favorite'] ?? ''}';

      _artist = item.artist;
      _title = item.title;
      _img = item.coverBig;
      notifyListeners();
      return true;
    }
    _queue.add(item);
    notifyListeners();
    return false;
  }

  MusicInfo enqueue([int i = 0]) {
    final item = _queue.removeAt(i);
    notifyListeners();
    return item;
  }

  void insert(MusicInfo item, [int? index]) {
    if ((index != null || _index != null) && (index ?? _index! - 1) >= 0) {
      _list.insert(index ?? _index! - 1, item);
      if (_index != null) _index = _index! + 1;
    } else {
      _list.add(item);
    }
    if (shuffled != null) {
      shuffle = true;
    } else {
      notifyListeners();
    }
  }

  void insertAll(Iterable<MusicInfo> items, [int? index]) {
    if ((index != null || _index != null) && (index ?? _index! - 1) >= 0) {
      _list.insertAll(index ?? _index! - 1, items);
      if (_index != null) _index = _index! + items.length;
    } else {
      _list.addAll(items);
    }
    if (shuffled != null) {
      shuffle = true;
    } else {
      notifyListeners();
    }
  }

  void replace(MusicInfo item, [int? index]) {
    final list = _shuffled ?? _list;
    list[index ?? _index!] = item;
    notifyListeners();
  }

  void replaceQueue(MusicInfo item, int index) {
    _queue[index] = item;
    notifyListeners();
  }
}

class PlaylistsModel extends ChangeNotifier {
  List<PlaylistVk>? _vkPlaylists;
  List<PlaylistVk>? get vkPlaylists => _vkPlaylists;
  set vkPlaylists(List<PlaylistVk>? value) {
    _vkPlaylists = value;
    notifyListeners();
  }
}
