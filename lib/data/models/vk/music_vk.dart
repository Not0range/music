import 'package:music/utils/utils.dart';

class MusicVk extends IMusic {
  final int id;
  final int ownerId;
  final String artist;
  final String title;
  final int duration;
  final String url;

  MusicVk(
      this.id, this.ownerId, this.artist, this.title, this.duration, this.url);

  factory MusicVk.fromJson(JsonMap json) {
    return MusicVk(json['id'], json['owner_id'], json['artist'], json['title'],
        json['duration'], json['url']);
  }

  @override
  MusicInfo get info => cacheInfo ??= MusicInfo(artist, title, url, duration);
}
