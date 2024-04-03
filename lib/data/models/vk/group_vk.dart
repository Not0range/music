import 'package:music/utils/utils.dart';

class GroupVk {
  final int id;
  final String title;
  final String avatar;
  final bool audioAccess;

  GroupVk(this.id, this.title, this.avatar, this.audioAccess);

  factory GroupVk.fromJson(JsonMap json) {
    return GroupVk(json['id'], json['name'], json['photo_100'],
        json['can_see_audio'] == 1);
  }
}
