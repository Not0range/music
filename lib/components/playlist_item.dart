import 'package:flutter/material.dart';
import 'package:music/components/loading_container.dart';
import 'package:music/utils/box_icons.dart';
import 'package:music/utils/service.dart';

import 'net_image.dart';

class PlaylistItem extends StatelessWidget {
  final String? leading;
  final String title;
  final VoidCallback? onTap;
  final Service? service;
  final PlaylistItemType type;
  final bool loading;

  const PlaylistItem(
      {super.key,
      this.leading,
      required this.title,
      this.onTap,
      this.service,
      required this.type})
      : loading = false;

  const PlaylistItem.loading({super.key, required this.type})
      : leading = null,
        title = '',
        onTap = null,
        service = null,
        loading = true;

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
    final Widget child;
    if (loading) {
      child = Row(
        children: [
          const LoadingContainer(
            width: 48,
            child: AspectRatio(aspectRatio: 1),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: LoadingContainer(
              child: Text(
                '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )),
        ],
      );
    } else {
      child = InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                clipBehavior: Clip.hardEdge,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(5)),
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
          ));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: child,
    );
  }
}

enum PlaylistItemType { music, user }
