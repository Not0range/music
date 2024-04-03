import 'package:music/utils/utils.dart';

class PlaylistVk extends IPlaylist {
  final int id;
  final int ownerId;
  final String title;
  final String photo;

  PlaylistVk(this.id, this.ownerId, this.title, this.photo);

  factory PlaylistVk.fromJson(JsonMap json) {
    final JsonMap? photo = json['photo'];

    return PlaylistVk(
        json['id'],
        json['owner_id'],
        json['title'],
        photo?['photo_1200'] ??
            photo?['photo_1200'] ??
            photo?['photo_600'] ??
            photo?['photo_300'] ??
            photo?['photo_270'] ??
            photo?['photo_135'] ??
            photo?['photo_68'] ??
            photo?['photo_34'] ??
            '');
  }

  @override
  PlaylistInfo get info =>
      cacheInfo ??= PlaylistInfo('${ownerId}_$id', title, photo);
}
