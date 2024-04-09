import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/loading_container.dart';
import 'package:music/components/net_image.dart';
import 'package:music/components/playing_icon.dart';
import 'package:music/utils/box_icons.dart';
import 'package:music/utils/constants.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/service_objects.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MusicItem extends StatelessWidget {
  final String id;
  final String artist;
  final String title;
  final String? img;
  final Service type;
  final VoidCallback? onPlay;
  final bool favorite;
  final Proc1<String>? onToggleFavorite;
  final Proc1<bool>? addToQueue;
  final int? reorderableIndex;
  final bool useContextMenu;
  final bool loading;

  const MusicItem({
    super.key,
    required this.id,
    required this.artist,
    required this.title,
    this.img,
    required this.type,
    this.onPlay,
    this.favorite = false,
    this.onToggleFavorite,
    this.addToQueue,
    this.reorderableIndex,
    this.useContextMenu = true,
  }) : loading = false;

  const MusicItem.loading({super.key})
      : id = '',
        artist = '',
        title = '',
        img = null,
        type = Service.local,
        onPlay = null,
        favorite = false,
        onToggleFavorite = null,
        addToQueue = null,
        reorderableIndex = null,
        useContextMenu = false,
        loading = true;

  IconData get _type {
    switch (type) {
      case Service.vk:
        return BoxIcons.vk;
      case Service.youtube:
        return BoxIcons.youtube;
      default:
        return Icons.storage;
    }
  }

  void _openContextMenu(BuildContext context) {
    openMenu(
        context, MusicInfo(id, artist, title, '', 0, false, img, img, type),
        favorite: favorite,
        onPlay: onPlay,
        onHeadQueue: () => addToQueue?.call(true),
        onTailQueue: () => addToQueue?.call(false),
        onToggleMyMusic: onToggleFavorite != null && type != Service.youtube
            ? () => onToggleFavorite?.call(id)
            : null,
        onToggleLike: onToggleFavorite != null && type == Service.youtube
            ? () => onToggleFavorite?.call(id)
            : null,
        onSearchRelated: () => _searchRelated(context),
        onShare: _share);
  }

  void _searchRelated(BuildContext context) {
    openPlaylist(context, AppLocalizations.of(context).relatedTracks,
        Playlist(type, PlaylistType.related, id));
  }

  void _share() {
    switch (type) {
      case Service.vk:
        Share.share('$vkShareBase$id');
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (loading) {
      child = Row(
        children: [
          const AspectRatio(
            aspectRatio: 1,
            child: LoadingContainer(),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LoadingContainer(
                  bottom: 5,
                  child: Text(
                    '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                LoadingContainer(
                  child: Text(
                    '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          )),
        ],
      );
    } else {
      child = InkWell(
        onTap: onPlay,
        onLongPress: useContextMenu ? () => _openContextMenu(context) : null,
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  NetImage(
                    img: img,
                    placeholder: const Icon(Icons.music_note),
                  ),
                  Consumer<PlayerModel>(
                      builder: (ctx, state, _) => Visibility(
                          visible: state.service == type && state.id == id,
                          child: PlayingIcon(animated: state.playing)))
                ],
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )),
            Icon(_type),
            if (reorderableIndex != null)
              ReorderableDelayedDragStartListener(
                  index: reorderableIndex!,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(Icons.drag_indicator),
                  ))
          ],
        ),
      );
    }
    return Container(
      height: 60,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: child,
    );
  }
}
