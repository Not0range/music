import 'package:flutter/material.dart';
import 'package:music/components/net_image.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/service_objects.dart';
import 'package:music/utils/utils.dart';

class PlaylistsCarousel extends StatefulWidget {
  final Iterable<IPlaylist> items;

  const PlaylistsCarousel({super.key, required this.items});

  @override
  State<StatefulWidget> createState() => _PlaylistsCarouselState();
}

class _PlaylistsCarouselState extends State<PlaylistsCarousel> {
  final _controller = PageController(viewportFraction: 1 / 2.5);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _builder(BuildContext context, int index) {
    final item = widget.items.elementAtOrNull(index)?.info;
    if (item == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: InkWell(
        onTap: () => openPlaylist(
            context, item.title, Playlist(Service.vk, false, item.id)),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(5)),
                child: NetImage(
                  img: item.cover,
                  placeholder: const Icon(Icons.library_music_outlined),
                ),
              ),
            ),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final size = MediaQuery.sizeOf(context);
    return SizedBox(
      height: size.width / 2,
      child: PageView.builder(
          controller: _controller,
          padEnds: false,
          itemCount: widget.items.length + 1,
          itemBuilder: _builder),
    );
  }
}
