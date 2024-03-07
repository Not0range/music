import 'package:flutter/material.dart';
import 'package:music/utils/box_icons.dart';

class MusicItem extends StatelessWidget {
  final String artist;
  final String title;
  final MusicItemType type;
  final VoidCallback? onPlay;
  final VoidCallback? openMenu;

  const MusicItem(
      {super.key,
      required this.artist,
      required this.title,
      required this.type,
      this.onPlay,
      this.openMenu});

  IconData get _type {
    switch (type) {
      case MusicItemType.vk:
        return BoxIcons.vk;
      case MusicItemType.youtube:
        return BoxIcons.youtube;
      default:
        return Icons.storage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: InkWell(
        onLongPress: openMenu,
        child: Row(
          children: [
            IconButton(onPressed: onPlay, icon: const Icon(Icons.play_circle)),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title),
                Text(artist),
              ],
            )),
            Icon(_type),
          ],
        ),
      ),
    );
  }
}

enum MusicItemType { local, vk, youtube }
