import 'service.dart';

class Playlist {
  final Service service;
  final bool favorite;
  final String? id;

  Playlist(this.service, this.favorite, [this.id]);
}

class User {
  final Service service;
  final String id;

  User(this.service, this.id);
}
