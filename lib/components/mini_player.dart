import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/net_image.dart';
import 'package:music/components/player.dart';
import 'package:music/utils/constants.dart';
import 'package:music/utils/scroll_command.dart';
import 'package:provider/provider.dart';

const _lastFactor = 200;

class MiniPlayer extends StatefulWidget {
  final StreamController<ScrollCommand> stream;

  const MiniPlayer({super.key, required this.stream});

  @override
  State<StatefulWidget> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  double? _start;
  double? _last;

  void _expand() {
    widget.stream.add(ScrollCommand(double.maxFinite, true));
  }

  void _playPause() {
    final player = Player.of(context);
    if (player.state == PlayerState.playing) {
      player.pause();
    } else {
      player.resume();
    }
  }

  Widget _builder(BuildContext context, PlayerModel state, Widget? _) {
    final p = state.position.inSeconds;
    final d = state.duration.inSeconds;
    final f = d > 0 ? p / d : 0.0;

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: NetImage(
                  img: state.img,
                  placeholder: Container(
                      alignment: Alignment.center,
                      color: Colors.grey,
                      child: const Icon(Icons.music_note)),
                ),
              ),
              Expanded(child: Text(state.title)),
              IconButton(
                  onPressed: _playPause,
                  icon: Icon(state.playing ? Icons.pause : Icons.play_arrow))
            ],
          ),
        ),
        FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: f,
          child: ColoredBox(color: Theme.of(context).primaryColor),
        )
      ],
    );
  }

  void _dragStart(DragStartDetails details) {
    _start = details.globalPosition.dy;
  }

  void _dragUpdate(DragUpdateDetails details) {
    if (_start == null) return;

    _last = _start! - details.globalPosition.dy;
    widget.stream.add(ScrollCommand(_last!, false));
  }

  void _dragEnd([DragEndDetails? details]) {
    final f = _last == null || _last! < _lastFactor ? 0.0 : double.maxFinite;
    widget.stream.add(ScrollCommand(f, true));
    _start = null;
    _last = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _expand,
      onVerticalDragStart: _dragStart,
      onVerticalDragUpdate: _dragUpdate,
      onVerticalDragEnd: _dragEnd,
      onVerticalDragCancel: _dragEnd,
      child: Container(
        height: toolBarHeight,
        decoration: BoxDecoration(boxShadow: const [
          BoxShadow(offset: Offset(0, -0.5), blurRadius: 5)
        ], color: Theme.of(context).scaffoldBackgroundColor),
        child: Consumer<PlayerModel>(builder: _builder),
      ),
    );
  }
}
