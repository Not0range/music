import 'package:flutter/material.dart';
import 'package:music/utils/box_icons.dart';
import 'package:music/utils/service.dart';

class PlaylistItem extends StatelessWidget {
  final Widget? leading;
  final String title;
  final VoidCallback? onTap;
  final Service? type;

  const PlaylistItem(
      {super.key, this.leading, required this.title, this.onTap, this.type});

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              leading ?? const SizedBox.shrink(),
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
          )),
    );
  }
}
