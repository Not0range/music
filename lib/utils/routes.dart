import 'package:flutter/material.dart';
import 'package:music/routes/playlist/playlist_route.dart';
import 'package:music/routes/results/results_route.dart';
import 'package:music/routes/settings/settings_route.dart';
import 'package:music/routes/user/user_route.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/service_objects.dart';
import 'package:music/utils/utils.dart';

void openPlaylist(BuildContext context, String title, Playlist playlist) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) => PlaylistRoute(title: title, playlist: playlist)));
}

void openUser(BuildContext context, String title, User user) {
  Navigator.push(context,
      MaterialPageRoute(builder: (ctx) => UserRoute(title: title, user: user)));
}

void openResults(
    BuildContext context, Service service, Iterable<IMusic> results,
    [String? title]) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) => ResultRoute(
                items: results,
                type: service,
                title: title,
              )));
}

void openSettings(BuildContext context) {
  showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      showDragHandle: true,
      builder: (ctx) => const SettingsRoute());
}
