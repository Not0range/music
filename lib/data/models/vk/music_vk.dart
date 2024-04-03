import 'package:music/utils/utils.dart';

class MusicVk extends IMusic {
  final int id;
  final int ownerId;
  final String artist;
  final String title;
  final int duration;
  final String url;
  final AlbumVk? album;

  MusicVk(this.id, this.ownerId, this.artist, this.title, this.duration,
      this.url, this.album);

  factory MusicVk.fromJson(JsonMap json) {
    return MusicVk(
        json['id'],
        json['owner_id'],
        json['artist'],
        json['title'],
        json['duration'],
        json['url'],
        json['album'] != null ? AlbumVk.fromJson(json['album']) : null);
  }

  @override
  MusicInfo get info => cacheInfo ??= MusicInfo('${ownerId}_$id', artist, title,
      url, duration, album?.smallCover, album?.bigCover);
}

class AlbumVk {
  final int id;
  final String title;
  final String? bigCover;
  final String? smallCover;

  AlbumVk(this.id, this.title, this.bigCover, this.smallCover);

  factory AlbumVk.fromJson(JsonMap json) {
    final thumb = json['thumb'];
    final big = thumb != null
        ? thumb['photo_1200'] ??
            thumb['photo_600'] ??
            thumb['photo_300'] ??
            thumb['photo_270'] ??
            thumb['photo_135'] ??
            thumb['photo_68'] ??
            thumb['photo_34']
        : null;

    final small = thumb != null
        ? thumb['photo_135'] ?? thumb['photo_68'] ?? thumb['photo_34']
        : null;
    return AlbumVk(json['id'], json['title'], big, small);
  }
}
