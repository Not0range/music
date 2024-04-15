import 'package:music/utils/service.dart';

class NewPlaylistModel {
  final Service type;
  final String title;
  final PrivacyType privacy;

  NewPlaylistModel(this.type, this.title, this.privacy);
}

enum PrivacyType { public, link, private }
