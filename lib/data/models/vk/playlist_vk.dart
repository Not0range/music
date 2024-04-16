import 'package:music/data/models/new_playlist_model.dart';
import 'package:music/utils/utils.dart';

class PlaylistVk extends IPlaylist {
  final int id;
  final int ownerId;
  final String title;
  final String photo;
  final bool private;
  final PlaylistPermissionsVk permissions;

  PlaylistVk(this.id, this.ownerId, this.title, this.photo, this.private,
      this.permissions);

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
            '',
        json['no_discover'] == true,
        PlaylistPermissionsVk.fromJson(json['permissions']));
  }

  @override
  PlaylistInfo get info => cacheInfo ??= PlaylistInfo.vk('${ownerId}_$id',
      title, photo, private ? PrivacyType.private : PrivacyType.public);
}

class PlaylistPermissionsVk {
  final bool play;
  final bool share;
  final bool edit;
  final bool follow;
  final bool delete;

  PlaylistPermissionsVk(
      this.play, this.share, this.edit, this.follow, this.delete);

  factory PlaylistPermissionsVk.fromJson(JsonMap json) {
    return PlaylistPermissionsVk(json['play'], json['share'], json['edit'],
        json['follow'], json['delete']);
  }
}

class PlaylistFollowVk {
  final int playlistId;
  final int ownerId;

  PlaylistFollowVk(this.playlistId, this.ownerId);

  factory PlaylistFollowVk.fromJson(JsonMap json) {
    return PlaylistFollowVk(json['playlist_id'], json['owner_id']);
  }
}
