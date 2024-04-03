import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/net_image.dart';
import 'package:music/components/player.dart';
import 'package:music/routes/player/components/progress_bar.dart';
import 'package:music/utils/service.dart';
import 'package:provider/provider.dart';

import 'player_presenter.dart';

class PlayerRoute extends StatefulWidget {
  final double position;

  const PlayerRoute({super.key, this.position = 0});

  @override
  State<StatefulWidget> createState() => _PlayerRouteState();
}

class _PlayerRouteState extends PlayerContract with PlayerPresenter {
  final _controller = DraggableScrollableController();

  @override
  void didUpdateWidget(covariant PlayerRoute oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollListener(widget.position);
  }

  @override
  void dispose() {
    _controller.dispose();
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
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: const [BoxShadow(blurRadius: 5)]),
      child: SingleChildScrollView(
        controller: controller,
        child: Consumer<PlayerModel>(builder: _consumerBuilder),
      ),
    );
  }

  Widget _consumerBuilder(BuildContext context, PlayerModel state, Widget? _) {
    final size = MediaQuery.sizeOf(context);
    final p = state.position.inSeconds;
    final d = state.duration.inSeconds;

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = scheme.primary;

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
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      iconSize: 36,
                      color: state.shuffle ? color : null,
                      onPressed: () => _toggleShuffle(state),
                      icon: const Icon(Icons.shuffle)),
                  IconButton(
                      iconSize: 36,
                      onPressed: () {},
                      icon: const Icon(Icons.fast_rewind)),
                  IconButton(
                      iconSize: 36,
                      onPressed: () => _playPause(state.playing),
                      icon:
                          Icon(state.playing ? Icons.pause : Icons.play_arrow)),
                  IconButton(
                      iconSize: 36,
                      onPressed: () {},
                      icon: const Icon(Icons.fast_forward)),
                  IconButton(
                      iconSize: 36,
                      color: state.repeat ? color : null,
                      onPressed: () => _toggleRepeat(state),
                      icon: const Icon(Icons.repeat)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10, bottom: 10),
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
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        state.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  )),
                  IconButton(
                      iconSize: 36,
                      color: state.favorite.isNotEmpty ? color : null,
                      onPressed: () => _toggleFavorite(
                          state.service,
                          state.isFavorite
                              ? FavoriteType.include
                              : state.favorite == 'restore'
                                  ? FavoriteType.restore
                                  : FavoriteType.exclude,
                          state.isFavorite ? state.favorite : state.id),
                      icon: Icon(state.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ProgressBar(
                max: d,
                value: p,
                onSeeking: _seek,
              ),
            ),
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

  void _toggleFavorite(Service? service, FavoriteType favorite, String? id) {
    if (id == null) return;

    final ids = id.split('_').map((e) => int.parse(e)).toList();
    if (service == Service.vk) {
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

  void _seek(int position) {
    Player.of(context).seek(Duration(seconds: position));
  }

  void _toggleShuffle(PlayerModel state) {
    state.shuffle = !state.shuffle;
    //TODO
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
    if (newId != null) {
      final owner = Provider.of<AppModel>(context, listen: false).vkProfile!.id;
      state.favorite = '${owner}_$newId';
    } else {
      if (state.favorite == state.id) {
        state.favorite = 'restore';
      } else {
        state.favorite = '';
      }
    }
  }

  @override
  void onError(String error) {
    // TODO: implement onError
  }
}

enum FavoriteType { include, exclude, restore }
