import 'package:flutter/material.dart';
import 'package:music/components/loading_container.dart';
import 'package:music/components/net_image.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/service_objects.dart';
import 'package:music/utils/utils.dart';

class PlaylistsCarousel extends StatefulWidget {
  final List<IPlaylist> items;
  final bool loading;

  const PlaylistsCarousel(
      {super.key, required this.items, this.loading = false});

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
    if (index >= widget.items.length) return const SizedBox.shrink();
    final item = widget.items[index].info;

    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: InkWell(
        onTap: () => openPlaylist(context, item.title,
            Playlist(Service.vk, PlaylistType.album, item.id)),
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
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _loadingBuilder(BuildContext context, int _) {
    return const Padding(
      padding: EdgeInsets.only(left: 10),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: LoadingContainer(),
          ),
          SizedBox(height: 5),
          LoadingContainer(
            child: Text(
              '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !widget.loading) return const SizedBox.shrink();

    final size = MediaQuery.sizeOf(context);
    return SizedBox(
      height: size.width / 2,
      child: PageView.builder(
          physics: widget.loading ? const NeverScrollableScrollPhysics() : null,
          controller: _controller,
          padEnds: false,
          itemCount: widget.loading ? null : widget.items.length + 1,
          itemBuilder: widget.loading ? _loadingBuilder : _builder),
    );
  }
}
