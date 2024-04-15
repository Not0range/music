import 'package:music/utils/utils.dart';

class GroupVk {
  final int id;
  final String title;
  final String avatar;

  GroupVk(this.id, this.title, this.avatar);

  factory GroupVk.fromJson(JsonMap json) {
    return GroupVk(json['id'], json['name'], json['photo_100']);
  }
}
