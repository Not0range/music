import 'package:flutter/material.dart';
import 'package:music/components/item_context_menu.dart';
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

void openResults(BuildContext context, Service service, List<IMusic> results,
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
      useSafeArea: true,
      builder: (ctx) => const SettingsRoute());
}

void openMenu(BuildContext context, MusicInfo info,
    {bool favorite = false,
    VoidCallback? onPlay,
    VoidCallback? onHeadQueue,
    VoidCallback? onTailQueue,
    VoidCallback? onToggleMyMusic,
    VoidCallback? onToggleLike,
    VoidCallback? onAddToPlaylist,
    VoidCallback? onSearchRelated,
    VoidCallback? onShare}) {
  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const LinearBorder(),
      elevation: 0,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => ItemContextMenu(
          info: info,
          favorite: favorite,
          onPlay: onPlay,
          onHeadQueue: onHeadQueue,
          onTailQueue: onTailQueue,
          onToggleMyMusic: onToggleMyMusic,
          onToggleLike: onToggleLike,
          onAddToPlaylist: onAddToPlaylist,
          onSearchRelated: onSearchRelated,
          onShare: onShare));
}
