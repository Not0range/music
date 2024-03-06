import 'package:music/utils/utils.dart';

class ProfileVk {
  final String firstName;
  final String lastName;

  ProfileVk(this.firstName, this.lastName);

  factory ProfileVk.fromJson(JsonMap json) {
    return ProfileVk(json['first_name'], json['last_name']);
  }

  String get name => '$lastName $firstName';
}
