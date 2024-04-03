import 'package:music/utils/utils.dart';

class UserVk {
  final int id;
  final String lastName;
  final String firstName;
  final String avatar;
  final bool audioAccess;

  UserVk(this.id, this.lastName, this.firstName, this.avatar, this.audioAccess);

  factory UserVk.fromJson(JsonMap json) {
    return UserVk(json['id'], json['last_name'], json['first_name'],
        json['photo_100'], json['can_see_audio'] == 1);
  }
}
