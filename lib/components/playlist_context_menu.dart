import 'package:flutter/material.dart';
import 'package:music/utils/box_icons.dart';
import 'package:music/utils/service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'net_image.dart';
import 'playlist_item.dart';

class PlaylistContextMenu extends StatelessWidget {
  final String title;
  final String? img;
  final Service service;
  final PlaylistItemType type;
  final VoidCallback? onPlay;
  final VoidCallback? onAddToCurrent;
  final VoidCallback? onHeadQueue;
  final VoidCallback? onTailQueue;
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;
  final VoidCallback? onFollow;

  const PlaylistContextMenu(
      {super.key,
      required this.title,
      this.img,
      required this.service,
      required this.type,
      this.onPlay,
      this.onAddToCurrent,
      this.onHeadQueue,
      this.onTailQueue,
      this.onRemove,
      this.onEdit,
      this.onFollow});

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
          title: title,
          service: service,
          type: type,
          leading: img,
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
                ListTile(
                  leading: const Icon(Icons.playlist_play),
                  title: Text(locale.addToCurrent),
                  onTap: () => _onTap(context, onAddToCurrent),
                ),
                if (onEdit != null)
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: Text(locale.editPlaylist),
                    onTap: () => _onTap(context, onEdit),
                  ),
                if (onRemove != null)
                  ListTile(
                    leading: const Icon(Icons.playlist_remove),
                    title: Text(locale.removePlaylist),
                    onTap: () => _onTap(context, onRemove),
                  ),
                if (onFollow != null)
                  ListTile(
                    leading: const Icon(Icons.playlist_add),
                    title: Text(locale.follow),
                    onTap: () => _onTap(context, onFollow),
                  ),
              ],
            ),
          ),
        )
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
  final String title;
  final Service service;
  final String? leading;
  final PlaylistItemType type;

  const _Preview({
    required this.title,
    required this.service,
    this.leading,
    required this.type,
  });

  IconData get _type {
    switch (service) {
      case Service.vk:
        return BoxIcons.vk;
      case Service.youtube:
        return BoxIcons.youtube;
      default:
        return Icons.storage;
    }
  }

  Widget _leadingBuilder(BuildContext context) {
    if (leading != null) {
      return NetImage(
        img: leading,
        placeholder: Icon(type == PlaylistItemType.music
            ? Icons.library_music_outlined
            : Icons.person),
      );
    }

    return Icon(
      type == PlaylistItemType.music ? Icons.favorite : Icons.person,
      size: 36,
      color: type == PlaylistItemType.music
          ? Theme.of(context).colorScheme.primary
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 0, 30, 10),
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(5), color: color),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            child: _leadingBuilder(context),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )),
          Icon(_type)
        ],
      ),
    );
  }
}
