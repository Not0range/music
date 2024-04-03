import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/net_image.dart';
import 'package:music/components/playing_icon.dart';
import 'package:music/utils/box_icons.dart';
import 'package:music/utils/service.dart';
import 'package:provider/provider.dart';

class MusicItem extends StatelessWidget {
  final String id;
  final String artist;
  final String title;
  final String? img;
  final Service type;
  final VoidCallback? onPlay;
  final VoidCallback? openMenu;

  const MusicItem({
    super.key,
    required this.id,
    required this.artist,
    required this.title,
    this.img,
    required this.type,
    this.onPlay,
    this.openMenu,
  });

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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: InkWell(
        onTap: onPlay,
        onLongPress: openMenu,
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
          ],
        ),
      ),
    );
  }
}
