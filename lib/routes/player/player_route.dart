import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/net_image.dart';
import 'package:music/routes/player/components/progress_bar.dart';
import 'package:music/utils/scroll_command.dart';
import 'package:provider/provider.dart';

class PlayerRoute extends StatefulWidget {
  final Stream<ScrollCommand> stream;

  const PlayerRoute({super.key, required this.stream});

  @override
  State<StatefulWidget> createState() => _PlayerRouteState();
}

class _PlayerRouteState extends State<PlayerRoute> {
  final _controller = DraggableScrollableController();
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    widget.stream.listen(_scrollListener);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scrollListener(ScrollCommand com) {
    if (!_controller.isAttached) return;

    final f = _controller.pixelsToSize(com.distance).clamp(0, 1).toDouble();
    if (com.animated) {
      _controller.animateTo(f,
          duration: const Duration(milliseconds: 200), curve: Curves.linear);
    } else {
      _controller.jumpTo(f);
    }
  }

  Widget _builder(BuildContext context, ScrollController controller) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: controller,
        child: Consumer<PlayerModel>(builder: _consumerBuilder),
      ),
    );
  }

  Widget _consumerBuilder(BuildContext context, PlayerModel state, Widget? _) {
    final size = MediaQuery.sizeOf(context);
    final p = state.position.inSeconds;
    final d = state.duration.inSeconds;

    return Column(children: [
      SizedBox(
        height: size.height * 0.9,
        width: size.width,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: NetImage(
                        img: state.img,
                        placeholder: ColoredBox(
                          color: Colors.grey,
                          child: Container(
                              alignment: Alignment.center,
                              color: Colors.grey,
                              child: const Icon(
                                Icons.music_note,
                                size: 72,
                              )),
                        )),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: Column(
                  children: [Text(state.title), Text(state.artist)],
                )),
                IconButton(onPressed: () {}, icon: Icon(Icons.favorite_border))
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ProgressBar(
                max: d,
                value: p,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.fast_rewind)),
                IconButton(
                    onPressed: () {},
                    icon: Icon(state.playing ? Icons.pause : Icons.play_arrow)),
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.fast_forward)),
              ],
            )
          ],
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        controller: _controller,
        initialChildSize: 0,
        minChildSize: 0,
        expand: false,
        snap: true,
        shouldCloseOnMinExtent: false,
        builder: _builder);
  }
}
