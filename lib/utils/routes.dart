import 'package:flutter/material.dart';
import 'package:music/components/item_context_menu.dart';
import 'package:music/components/main_dialog.dart';
import 'package:music/components/playlist_context_menu.dart';
import 'package:music/components/playlist_item.dart';
import 'package:music/routes/add_to_playlist/add_to_playlist_route.dart';
import 'package:music/routes/playlist/playlist_route.dart';
import 'package:music/routes/results/results_route.dart';
import 'package:music/routes/settings/settings_route.dart';
import 'package:music/routes/media/components/create_playlist_dialog.dart';
import 'package:music/routes/media/components/select_service_dialog.dart';
import 'package:music/routes/tabs/components/filter_dialog.dart';
import 'package:music/routes/user/user_route.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/service_objects.dart';
import 'package:music/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../data/models/new_playlist_model.dart';

void openPlaylist(
    BuildContext context, String title, Playlist playlist, bool editable) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) => PlaylistRoute(
                title: title,
                playlist: playlist,
                editable: editable,
              )));
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

void openItemMenu(BuildContext context, MusicInfo? info,
    {bool favorite = false,
    VoidCallback? onPlay,
    VoidCallback? onHeadQueue,
    VoidCallback? onTailQueue,
    VoidCallback? onRemoveFromQueue,
    VoidCallback? onToggleMyMusic,
    VoidCallback? onToggleLike,
    VoidCallback? onAddToPlaylist,
    VoidCallback? onRemoveFromCurrent,
    VoidCallback? onRemoveFromPlaylist,
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
          onRemoveFromQueue: onRemoveFromQueue,
          onToggleMyMusic: onToggleMyMusic,
          onToggleLike: onToggleLike,
          onAddToPlaylist: onAddToPlaylist,
          onRemoveFromPlaylist: onRemoveFromPlaylist,
          onRemoveFromCurrent: onRemoveFromCurrent,
          onSearchRelated: onSearchRelated,
          onShare: onShare));
}

void openPlaylistMenu(
    BuildContext context, String title, Service service, PlaylistItemType type,
    {String? img,
    VoidCallback? onPlay,
    VoidCallback? onAddToCurrent,
    VoidCallback? onHeadQueue,
    VoidCallback? onTailQueue,
    VoidCallback? onRemove,
    VoidCallback? onEdit,
    VoidCallback? onFollow}) {
  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const LinearBorder(),
      elevation: 0,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => PlaylistContextMenu(
            title: title,
            service: service,
            type: type,
            img: img,
            onPlay: onPlay,
            onAddToCurrent: onAddToCurrent,
            onHeadQueue: onHeadQueue,
            onTailQueue: onTailQueue,
            onRemove: onRemove,
            onEdit: onEdit,
            onFollow: onFollow,
          ));
}

Future<NewPlaylistModel?> openServiceSelector(BuildContext context) async {
  final result = await showModalBottomSheet<Service>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (ctx) => const SelectServiceDialog());
  if (result == null || !context.mounted) return null;

  return await openEditPlaylist(context, result);
}

Future<NewPlaylistModel?> openEditPlaylist(
    BuildContext context, Service service,
    {String title = '', PrivacyType privacy = PrivacyType.public}) async {
  return await showDialog<NewPlaylistModel>(
      context: context,
      builder: (ctx) => CreatePlaylistDialog(
            type: service,
            title: title,
            privacy: privacy,
          ));
}

Future<List<bool>?> openFilterDialog(
  BuildContext context, {
  bool details = false,
  bool vk = false,
  bool vkFriends = false,
  bool vkGroups = false,
  bool youtube = false,
}) async {
  return await showModalBottomSheet<List<bool>>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) => FilterDialog(
            details: details,
            vk: vk,
            vkFriends: vkFriends,
            vkGroups: vkGroups,
            youtube: youtube,
          ));
}

void showYesNoDialog(BuildContext context, String text,
    {VoidCallback? yes,
    VoidCallback? no,
    bool dangerYes = false,
    bool dangerNo = false}) {
  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const LinearBorder(),
      elevation: 0,
      useRootNavigator: true,
      useSafeArea: true,
      builder: (ctx) => MainDialog(text: text, actions: [
            MainDialogAction(
                AppLocalizations.of(context).yes,
                yes,
                dangerYes
                    ? MainDialogActionType.danger
                    : MainDialogActionType.common),
            MainDialogAction(
                AppLocalizations.of(context).no,
                no,
                dangerNo
                    ? MainDialogActionType.danger
                    : MainDialogActionType.common),
          ]));
}

Future<String?> showAddToPlaylistDialog(
    BuildContext context, String id, Service service) async {
  return await showModalBottomSheet<String>(
      context: context,
      clipBehavior: Clip.hardEdge,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => AddToPlaylistRoute(id: id, service: service));
}
