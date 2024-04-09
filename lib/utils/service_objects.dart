import 'service.dart';

class Playlist {
  final Service service;
  final PlaylistType type;
  final String? id;

  Playlist(this.service, this.type, [this.id]);
}

enum PlaylistType { favorite, album, related }

class User {
  final Service service;
  final String id;

  User(this.service, this.id);
}
