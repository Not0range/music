import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/net_image.dart';
import 'package:music/routes/player/components/progress_bar.dart';
import 'package:music/routes/player_wrapper/player_wrapper.dart';
import 'package:music/utils/player_helper.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/styles.dart';
import 'package:provider/provider.dart';

class PlayerRoute extends StatefulWidget {
  final EdgeInsets insets;

  const PlayerRoute({
    super.key,
    this.insets = EdgeInsets.zero,
  });

  @override
  State<StatefulWidget> createState() => _PlayerRouteState();
}

class _PlayerRouteState extends State<PlayerRoute> {
  final _controller = DraggableScrollableController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              SizedBox(height: widget.insets.top),
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
      ],
    );
  }

  Widget _consumerBuilder(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final state = Provider.of<PlayerModel>(context);
    final p = state.position;
    final d = state.duration;

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
              onPressed: () => showPlayerPlaylist(context, widget.insets,
                  onPrev: _prev, onNext: _next, onPlayPause: _playPause),
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
            onPressed: _toggleShuffle,
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
            onPressed: _toggleRepeat,
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
              onPressed: _toggleFavorite,
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
            onPressed: () => _controller.animateTo(0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.linear),
            icon: const Icon(Icons.expand_more)),
        IconButton(
            iconSize: playerIconSize,
            onPressed: () {},
            icon: const Icon(Icons.more_vert)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        controller: _controller,
        initialChildSize: 1,
        minChildSize: 0.7,
        expand: false,
        snap: true,
        builder: _builder);
  }

  void _toggleFavorite() {
    PlayerWrapper.of(context).toggleFavorite();
  }

  void _playPause(bool playing) {
    PlayerWrapper.of(context).playPause(playing);
  }

  void _prev() {
    PlayerWrapper.of(context).prev();
  }

  void _next() {
    PlayerWrapper.of(context).next();
  }

  void _seek(double position) {
    PlayerHelper.instance.seek(position);
  }

  void _toggleShuffle() {
    PlayerWrapper.of(context).toggleShuffle();
  }

  void _toggleRepeat() {
    PlayerWrapper.of(context).toggleRepeat();
  }
}
