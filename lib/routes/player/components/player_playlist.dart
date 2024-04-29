import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/music_item.dart';
import 'package:music/components/player.dart';
import 'package:music/utils/player_helper.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/styles.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sliver_tools/sliver_tools.dart';

class PlayerPlaylist extends StatefulWidget {
  final VoidCallback? prev;
  final Proc1<bool>? playPause;
  final VoidCallback? next;
  final EdgeInsets insets;

  const PlayerPlaylist(
      {super.key,
      this.prev,
      this.playPause,
      this.next,
      this.insets = EdgeInsets.zero});

  @override
  State<StatefulWidget> createState() => _PlayerPlaylistState();
}

class _PlayerPlaylistState extends State<PlayerPlaylist> {
  final _controller = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _builder(BuildContext context, ScrollController controller) {
    final locale = AppLocalizations.of(context);
    final t = Theme.of(context);
    final bg = t.scaffoldBackgroundColor;

    final state = Provider.of<PlayerModel>(context);
    final list = state.shuffled ?? state.list;
    final len = list.length - (state.fromQueue ? 0 : 1);

    return ColoredBox(
      color: bg.withOpacity(0.5),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: widget.insets.top),
              IconButton(
                  iconSize: playerIconSize,
                  onPressed: () => _controller.animateTo(0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.linear),
                  icon: const Icon(Icons.close)),
              if (state.id != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  padding: const EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: t.dividerColor))),
                  child: MusicItem(
                    id: state.id!,
                    artist: state.artist,
                    title: state.title,
                    type: state.service ?? Service.local,
                    img: state.img,
                  ),
                ),
              Expanded(
                child: CustomScrollView(
                  controller: controller,
                  slivers: [
                    if (state.queue.isNotEmpty)
                      MultiSliver(pushPinnedChildren: true, children: [
                        SliverPinnedHeader(
                            child: Container(
                          padding: const EdgeInsets.all(8),
                          color: bg.withOpacity(0.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                locale.queue,
                                style: t.textTheme.bodyLarge,
                              ),
                              InkWell(
                                  onTap: () => state.queue = [],
                                  child: Text(
                                    locale.clear,
                                    style: t.textTheme.bodyLarge,
                                  ))
                            ],
                          ),
                        )),
                        SliverReorderableList(
                            itemBuilder: (ctx, i) => _queueBuilder(state, i),
                            itemCount: state.queue.length,
                            onReorder: state.reorderQueue)
                      ]),
                    MultiSliver(pushPinnedChildren: true, children: [
                      SliverPinnedHeader(
                          child: Container(
                        padding: const EdgeInsets.all(8),
                        color: bg.withOpacity(0.5),
                        child: Text(
                          locale.playlist,
                          style: t.textTheme.bodyLarge,
                        ),
                      )),
                      SliverReorderableList(
                          itemBuilder: (ctx, i) =>
                              _playlistBuilder(state, i, controller),
                          itemCount: math.max(len, 0),
                          onReorder: (o, n) => state.reorder(
                              (o + 1 + state.index!) % list.length,
                              (n + 1 + state.index!) % list.length))
                    ]),
                  ],
                ),
              ),
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                      iconSize: playerIconSize,
                      onPressed: widget.prev,
                      icon: const Icon(Icons.fast_rewind)),
                  IconButton(
                      iconSize: playerIconSize * 2,
                      onPressed: () => widget.playPause?.call(state.playing),
                      icon: Icon(state.playing
                          ? Icons.pause_circle
                          : Icons.play_circle)),
                  IconButton(
                      iconSize: playerIconSize,
                      onPressed: widget.next,
                      icon: const Icon(Icons.fast_forward)),
                  const Spacer(),
                ],
              ),
              SizedBox(height: widget.insets.bottom)
            ],
          ),
        ),
      ),
    );
  }

  void _addToQueue(MusicInfo item, bool head) {
    final state = Provider.of<PlayerModel>(context, listen: false);
    if (head) {
      state.headQueue([item]);
    } else {
      state.tailQueue([item]);
    }
  }

  Widget _queueBuilder(PlayerModel state, int i) {
    final item = state.queue[i];
    return Material(
      key: Key(item.id),
      type: MaterialType.transparency,
      child: MusicItem(
        id: item.id,
        artist: item.artist,
        title: item.title,
        type: item.type,
        img: item.coverSmall,
        reorderableIndex: i,
        onPlay: () => _playQueue(i),
        removeFromQueue: () => state.enqueue(i),
      ),
    );
  }

  Widget _playlistBuilder(
      PlayerModel state, int i, ScrollController controller) {
    final list = state.shuffled ?? state.list;
    final index = (state.index! + i + 1) % list.length;
    final item = list[index];
    return Material(
      key: Key(item.id),
      type: MaterialType.transparency,
      child: MusicItem(
        id: item.id,
        artist: item.artist,
        title: item.title,
        type: item.type,
        img: item.coverSmall,
        reorderableIndex: i,
        onPlay: () => _play(item, index, controller),
        addToQueue: (h) => _addToQueue(item, h),
        removeFromCurrent: () => state.removeAt(index),
      ),
    );
  }

  void _play(MusicInfo item, int index, ScrollController controller) {
    controller.animateTo(0,
        duration: const Duration(milliseconds: 200), curve: Curves.linear);

    final state = Provider.of<PlayerModel>(context, listen: false);

    state.setItem(item);
    state.index = index;
    if (item.url.isNotEmpty) {
      PlayerHelper.instance.play(item.url, item.toJson());
    } else {
      PlayerCommand.sendCommand(
          context,
          BroadcastCommand(
              BroadcastCommandType.needUrl, item.type, {'fromQueue': false}));
    }
  }

  void _playQueue(int index) {
    final state = Provider.of<PlayerModel>(context, listen: false);

    final item = state.enqueue(index);
    state.setItem(item);
    if (item.url.isNotEmpty) {
      PlayerHelper.instance.play(item.url, item.toJson());
    } else {
      PlayerCommand.sendCommand(
          context,
          BroadcastCommand(
              BroadcastCommandType.needUrl, item.type, {'fromQueue': true}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        controller: _controller,
        initialChildSize: 1,
        minChildSize: 0.5,
        expand: false,
        snap: true,
        builder: _builder);
  }
}
