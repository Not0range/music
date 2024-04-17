import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/net_image.dart';
import 'package:music/components/player.dart';
import 'package:music/routes/player/components/progress_bar.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/styles.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';

import 'components/player_playlist.dart';
import 'player_presenter.dart';

class PlayerRoute extends StatefulWidget {
  final double position;
  final double topInset;
  final VoidCallback? onClosed;

  const PlayerRoute(
      {super.key, this.position = 0, this.topInset = 0, this.onClosed});

  @override
  State<StatefulWidget> createState() => _PlayerRouteState();
}

class _PlayerRouteState extends PlayerContract with PlayerPresenter {
  late final StreamSubscription _subscription;

  final _controller = DraggableScrollableController();
  final _playlistController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.size == 0) widget.onClosed?.call();
    });
    Future.delayed(Duration.zero, () {
      Player.streamOf(context).listen((cmd) {
        switch (cmd.type) {
          case BroadcastCommandType.needUrl:
            final id = Provider.of<PlayerModel>(context, listen: false).id!;
            switch (cmd.service) {
              case Service.vk:
                getByIdVk(cmd.params?['fromQueue'] == true, id);
                break;
              default:
            }
            break;
          case BroadcastCommandType.playPause:
            _playPause(cmd.params?['playing'] ?? false);
            break;
          case BroadcastCommandType.next:
            _next();
            break;
          default:
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant PlayerRoute oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollListener(widget.position);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.dispose();
    _playlistController.dispose();
    super.dispose();
  }

  void _scrollListener(double position) {
    if (!_controller.isAttached) return;

    final f = _controller.pixelsToSize(position).clamp(0, 1).toDouble();
    if (position <= 0 || position.isInfinite) {
      _controller.animateTo(f,
          duration: const Duration(milliseconds: 200), curve: Curves.linear);
    } else {
      _controller.jumpTo(f);
    }
  }

  Widget _builder(BuildContext context, ScrollController controller) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: const [BoxShadow(blurRadius: 5)]),
          child: Column(
            children: [
              SizedBox(height: widget.topInset),
              _topPanel(),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Builder(builder: _consumerBuilder),
                ),
              ),
            ],
          ),
        ),
        PlayerPlaylist(
          topInset: widget.topInset,
          controller: _playlistController,
          prev: _prev,
          playPause: _playPause,
          next: _next,
        ),
      ],
    );
  }

  Widget _consumerBuilder(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final state = Provider.of<PlayerModel>(context,
        listen: _controller.isAttached && _controller.size > 0);
    final p = state.position.inSeconds;
    final d = state.duration.inSeconds;

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = scheme.primary;

    return Column(children: [
      SizedBox(
        height: size.height * 0.80,
        width: size.width,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: NetImage(
                        img: state.img,
                        placeholder: ColoredBox(
                          color: Colors.grey,
                          child: Container(
                              alignment: Alignment.center,
                              color: scheme.inversePrimary,
                              child: const Icon(
                                Icons.music_note,
                                size: 72,
                              )),
                        )),
                  ),
                ),
              ),
            ),
            _title(state, theme.textTheme.bodyLarge, color),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: ProgressBar(
                max: d,
                value: p,
                onSeeking: _seek,
              ),
            ),
            _control(state, color),
            _bottomPanel()
          ],
        ),
      ),
      //TODO lyrics box
    ]);
  }

  Widget _bottomPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              iconSize: playerIconSize / 1.5,
              onPressed: () {},
              icon: const Icon(Icons.reply)),
          IconButton(
              iconSize: playerIconSize / 1.5,
              onPressed: () => _playlistController.animateTo(1,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.linear),
              icon: const Icon(Icons.playlist_play))
        ],
      ),
    );
  }

  Widget _control(PlayerModel state, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
            iconSize: playerIconSize,
            color: state.shuffled != null ? color : null,
            onPressed: () => _toggleShuffle(state),
            icon: const Icon(Icons.shuffle)),
        IconButton(
            iconSize: playerIconSize,
            onPressed: _prev,
            icon: const Icon(Icons.fast_rewind)),
        IconButton(
            iconSize: playerIconSize * 2,
            onPressed: () => _playPause(state.playing),
            icon: Icon(state.playing ? Icons.pause_circle : Icons.play_circle)),
        IconButton(
            iconSize: playerIconSize,
            onPressed: _next,
            icon: const Icon(Icons.fast_forward)),
        IconButton(
            iconSize: playerIconSize,
            color: state.repeat ? color : null,
            onPressed: () => _toggleRepeat(state),
            icon: const Icon(Icons.repeat)),
      ],
    );
  }

  Widget _title(PlayerModel state, TextStyle? style, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 10, bottom: 5),
      child: Row(
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
              Text(
                state.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            ],
          )),
          IconButton(
              iconSize: playerIconSize,
              color: state.favorite.isNotEmpty ? color : null,
              onPressed: () => _toggleFavorite(
                  state.service,
                  state.isFavorite
                      ? FavoriteType.include
                      : state.favorite == 'restore'
                          ? FavoriteType.restore
                          : FavoriteType.exclude,
                  state.isFavorite ? state.favorite : state.id),
              icon: Icon(
                  state.isFavorite ? Icons.favorite : Icons.favorite_border))
        ],
      ),
    );
  }

  Widget _topPanel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            iconSize: playerIconSize,
            onPressed: () => _scrollListener(0),
            icon: const Icon(Icons.expand_more)),
        IconButton(
            iconSize: playerIconSize,
            onPressed: () => _scrollListener(0),
            icon: const Icon(Icons.more_vert)),
      ],
    );
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

  void _toggleFavorite(Service? service, FavoriteType favorite, String? id) {
    if (id == null) return;

    if (service == Service.vk) {
      final ids = id.split('_').map((e) => int.parse(e)).toList();
      if (favorite == FavoriteType.include) {
        final id = Provider.of<AppModel>(context, listen: false).vkProfile?.id;
        if (id != null) removeVk(id, ids[1]);
      } else if (favorite == FavoriteType.exclude) {
        addVk(ids[0], ids[1]);
      } else {
        restoreVk(ids[0], ids[1]);
      }
    }
  }

  void _playPause(bool playing) {
    final player = Player.of(context);
    if (!playing) {
      player.resume();
    } else {
      player.pause();
    }
  }

  void _prev() {
    final state = Provider.of<PlayerModel>(context, listen: false);
    if (state.index == null) return;

    var i = state.index! - 1;
    if (i < 0) i = state.list.length - 1;

    state.index = i;
    final item = (state.shuffled ?? state.list)[i];
    state.setItem(item, favorite: '${item.extra?['favorite'] ?? ''}');

    if (item.url.isNotEmpty) {
      Player.of(context).play(UrlSource(item.url));
    } else {
      Player.sendCommand(
          context,
          BroadcastCommand(
              BroadcastCommandType.needUrl, item.type, {'fromQueue': false}));
    }
  }

  void _next() {
    final state = Provider.of<PlayerModel>(context, listen: false);

    if (state.index != null) {
      var i = state.index! + 1;
      if (i >= state.list.length) i = 0;

      state.index = i;
    }

    final MusicInfo item;
    final bool fromQueue;
    if (state.queue.isNotEmpty) {
      item = state.enqueue();
      fromQueue = true;
    } else {
      if (state.index == null) return;
      item = (state.shuffled ?? state.list)[state.index!];
      fromQueue = false;
    }
    state.fromQueue = fromQueue;
    state.setItem(item, favorite: '${item.extra?['favorite'] ?? ''}');

    if (item.url.isNotEmpty) {
      Player.of(context).play(UrlSource(item.url));
    } else {
      Player.sendCommand(
          context,
          BroadcastCommand(BroadcastCommandType.needUrl, item.type,
              {'fromQueue': fromQueue}));
    }
  }

  void _seek(int position) {
    Player.of(context).seek(Duration(seconds: position));
  }

  void _toggleShuffle(PlayerModel state) {
    if (state.list.isEmpty) return;
    state.shuffle = state.shuffled == null;
  }

  void _toggleRepeat(PlayerModel state) {
    state.repeat = !state.repeat;
    final player = Player.of(context);
    if (state.repeat) {
      player.setReleaseMode(ReleaseMode.loop);
    } else {
      player.setReleaseMode(ReleaseMode.stop);
    }
  }

  @override
  void onFavoriteSuccess([int? newId]) {
    final state = Provider.of<PlayerModel>(context, listen: false);
    final String favorite;

    if (newId != null) {
      final owner = Provider.of<AppModel>(context, listen: false).vkProfile!.id;
      favorite = '${owner}_$newId';
    } else {
      if (state.favorite == state.id) {
        favorite = 'restore';
      } else {
        favorite = '';
      }
    }
    state.favorite = favorite;
    if (!state.fromQueue) {
      state.replace((state.shuffled ?? state.list)[state.index!]
          .copyWith(extra: {'favorite': favorite}));
    }
  }

  @override
  void onLyricsSuccess(String lyrics) {
    // TODO: implement onLyricsSuccess
  }

  @override
  void onError(String error) {
    // TODO: implement onError
  }

  @override
  void onUrlSuccess(bool fromQueue, MusicInfo item) {
    final state = Provider.of<PlayerModel>(context, listen: false);

    state.setItem(item);
    if (!fromQueue) state.replace(item);

    final player = Player.of(context);

    if (player.source != null) {
      player.play(UrlSource(item.url));
    } else {
      player.setSource(UrlSource(item.url));
    }
  }
}

enum FavoriteType { include, exclude, restore }
