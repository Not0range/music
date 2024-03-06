import 'package:music/utils/utils.dart';

class ProfileVk {
  final int id;
  final String firstName;
  final String lastName;
  final String avatar;

  ProfileVk(this.id, this.firstName, this.lastName, this.avatar);

  factory ProfileVk.fromJson(JsonMap json) {
    return ProfileVk(
        json['id'], json['first_name'], json['last_name'], json['photo_200']);
  }

  String get name => '$lastName $firstName';
}
