import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/net_image.dart';
import 'package:music/components/player.dart';
import 'package:music/utils/constants.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';

const _lastFactor = 200;

class MiniPlayer extends StatefulWidget {
  final Proc1<double>? onChangePosition;

  const MiniPlayer({super.key, this.onChangePosition});

  @override
  State<StatefulWidget> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  double? _start;
  double? _last;

  void _expand() {
    widget.onChangePosition?.call(double.infinity);
  }

  void _playPause(bool playing) {
    Player.sendCommand(
        context,
        BroadcastCommand(BroadcastCommandType.playPause, Service.local,
            {'playing': playing}));
  }

  void _next() {
    Player.sendCommand(
        context, BroadcastCommand(BroadcastCommandType.next, Service.local));
  }

  Widget _builder(BuildContext context, PlayerModel state, Widget? _) {
    final p = state.position.inSeconds;
    final d = state.duration.inSeconds;
    final f = d > 0 ? p / d : 0.0;

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                      color: scheme.inversePrimary,
                      child: const Icon(Icons.music_note)),
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  state.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge,
                ),
              )),
              IconButton(
                  onPressed: () => _playPause(state.playing),
                  icon: Icon(state.playing ? Icons.pause : Icons.play_arrow)),
              IconButton(onPressed: _next, icon: const Icon(Icons.fast_forward))
            ],
          ),
        ),
        FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: f,
          child: Container(height: 2, color: scheme.primary),
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
    widget.onChangePosition?.call(_last!);
  }

  void _dragEnd([DragEndDetails? details]) {
    final f = _last == null || _last! < _lastFactor ? 0.0 : double.infinity;
    widget.onChangePosition?.call(f);
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
