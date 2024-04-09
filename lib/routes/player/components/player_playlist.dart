import 'dart:ui';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/music_item.dart';
import 'package:music/components/player.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/styles.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sliver_tools/sliver_tools.dart';

class PlayerPlaylist extends StatefulWidget {
  final double topInset;
  final DraggableScrollableController controller;

  const PlayerPlaylist(
      {super.key, this.topInset = 0, required this.controller});

  @override
  State<StatefulWidget> createState() => _PlayerPlaylistState();
}

class _PlayerPlaylistState extends State<PlayerPlaylist> {
  bool _openned = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    if (!widget.controller.isAttached) return;

    if (_openned && widget.controller.size > 0) {
      setState(() => _openned = true);
    } else if (!_openned && widget.controller.size <= 0) {
      setState(() => _openned = false);
    }
  }

  Widget _builder(BuildContext context, ScrollController controller) {
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
              SizedBox(height: widget.topInset),
              IconButton(
                  iconSize: playerIconSize,
                  onPressed: () => widget.controller.animateTo(0,
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
                          child: Text(
                            AppLocalizations.of(context).queue,
                            style: t.textTheme.bodyLarge,
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
                          AppLocalizations.of(context).playlist,
                          style: t.textTheme.bodyLarge,
                        ),
                      )),
                      SliverReorderableList(
                          itemBuilder: (ctx, i) => _playlistBuilder(state, i),
                          itemCount: math.max(len, 0),
                          onReorder: (o, n) => state.reorder(
                              (o + 1 + state.index!) % list.length,
                              (n + 1 + state.index!) % list.length))
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        type: state.service ?? Service.local,
        img: item.coverSmall,
        reorderableIndex: i,
        onPlay: () => _playQueue(i),
      ),
    );
  }

  Widget _playlistBuilder(PlayerModel state, int i) {
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
        type: state.service ?? Service.local,
        img: item.coverSmall,
        reorderableIndex: i,
        onPlay: () => _play(item, index),
      ),
    );
  }

  void _play(MusicInfo item, int index) {
    final state = Provider.of<PlayerModel>(context, listen: false);

    state.setItem(item);
    state.index = index;
    Player.of(context).play(UrlSource(item.url));
  }

  void _playQueue(int index) {
    final state = Provider.of<PlayerModel>(context, listen: false);

    final item = state.enqueue(index);
    state.setItem(item);
    Player.of(context).play(UrlSource(item.url));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        controller: widget.controller,
        initialChildSize: 0,
        minChildSize: 0,
        shouldCloseOnMinExtent: false,
        expand: false,
        snap: true,
        builder: _builder);
  }
}
