import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:music/utils/utils.dart';

import 'net_image.dart';

class ItemContextMenu extends StatelessWidget {
  final MusicInfo info;
  final bool favorite;
  final VoidCallback? onPlay;
  final VoidCallback? onHeadQueue;
  final VoidCallback? onTailQueue;
  final VoidCallback? onToggleMyMusic;
  final VoidCallback? onToggleLike;
  final VoidCallback? onAddToPlaylist;
  final VoidCallback? onSearchRelated;
  final VoidCallback? onShare;
  final VoidCallback? onRemoveFromPlaylist;

  const ItemContextMenu(
      {super.key,
      required this.info,
      this.favorite = false,
      this.onPlay,
      this.onHeadQueue,
      this.onTailQueue,
      this.onToggleMyMusic,
      this.onToggleLike,
      this.onAddToPlaylist,
      this.onSearchRelated,
      this.onShare,
      this.onRemoveFromPlaylist});

  void _onTap(BuildContext context, [VoidCallback? action]) {
    Navigator.pop(context);
    action?.call();
  }

  Widget _builder(BuildContext context, ScrollController controller) {
    final t = Theme.of(context);
    final locale = AppLocalizations.of(context);

    return Column(
      children: [
        _Preview(
          artist: info.artist,
          title: info.title,
          img: info.coverSmall,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: t.colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28))),
            child: ListView(
              controller: controller,
              children: [
                if (onPlay != null)
                  ListTile(
                    leading: const Icon(Icons.play_arrow),
                    title: Text(locale.play),
                    onTap: () => _onTap(context, onPlay),
                  ),
                if (onHeadQueue != null)
                  ListTile(
                    leading: const Icon(Icons.segment),
                    title: Text(locale.headQueue),
                    onTap: () => _onTap(context, onHeadQueue),
                  ),
                if (onTailQueue != null)
                  ListTile(
                    leading: Transform.scale(
                        scaleY: -1, child: const Icon(Icons.segment)),
                    title: Text(locale.tailQueue),
                    onTap: () => _onTap(context, onTailQueue),
                  ),
                if (onToggleMyMusic != null)
                  ListTile(
                    leading:
                        Icon(favorite ? Icons.favorite_border : Icons.favorite),
                    title: Text(favorite
                        ? locale.removeFromMyMusic
                        : locale.addToMyMusic),
                    onTap: () => _onTap(context, onToggleMyMusic),
                  ),
                if (onToggleLike != null)
                  ListTile(
                    leading: Icon(favorite ? Icons.thumb_down : Icons.thumb_up),
                    title: Text(favorite ? locale.dislike : locale.like),
                    onTap: () => _onTap(context, onToggleLike),
                  ),
                ListTile(
                  leading: const Icon(Icons.playlist_add),
                  title: Text(locale.addToPlaylist),
                  onTap: () => _onTap(context, onAddToPlaylist),
                ),
                if (onRemoveFromPlaylist != null)
                  ListTile(
                    leading: const Icon(Icons.playlist_remove),
                    title: Text(locale.removeFromPlaylist),
                    onTap: () => _onTap(context, onRemoveFromPlaylist),
                  ),
                ListTile(
                  leading: const Icon(Icons.manage_search),
                  title: Text(locale.searchRelated),
                  onTap: () => _onTap(context, onSearchRelated),
                ),
                ListTile(
                  leading: const Icon(Icons.reply),
                  title: Text(locale.share),
                  onTap: () => _onTap(context, onShare),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false, maxChildSize: 0.75, builder: _builder);
  }
}

class _Preview extends StatelessWidget {
  final String artist;
  final String title;
  final String? img;

  const _Preview({required this.artist, required this.title, this.img});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      height: 70,
      margin: const EdgeInsets.fromLTRB(15, 0, 30, 10),
      padding: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(5), color: color),
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: NetImage(
              img: img,
              placeholder: const Icon(Icons.music_note),
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
        ],
      ),
    );
  }
}
