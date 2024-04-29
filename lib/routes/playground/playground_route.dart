import 'package:flutter/material.dart';
import 'package:music/utils/player_helper.dart';

class PlayGroundRoute extends StatefulWidget {
  const PlayGroundRoute({super.key});

  @override
  State<StatefulWidget> createState() => _PlayGroundRouteState();
}

class _PlayGroundRouteState extends State<PlayGroundRoute> {
  Future<void> _start() async {
    await PlayerHelper.instance.play(
        'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        OutlinedButton(onPressed: _start, child: const Text('Play')),
        OutlinedButton(
            onPressed: () => PlayerHelper.instance.pause(),
            child: const Text('Pause')),
      ],
    ));
  }
}
