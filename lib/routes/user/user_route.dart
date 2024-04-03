import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/music_item.dart';
import 'package:music/components/player.dart';
import 'package:music/data/models/vk/music_vk.dart';
import 'package:music/data/models/vk/playlist_vk.dart';
import 'package:music/routes/user/components/playlists_carousel.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/service_objects.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';

import 'user_presenter.dart';

class UserRoute extends StatefulWidget {
  final String title;
  final User user;

  const UserRoute({super.key, required this.title, required this.user});

  @override
  State<StatefulWidget> createState() => _UserRouteState();
}

class _UserRouteState extends UserContract with UserPresenter {
  Service _type = Service.local;
  Iterable<IMusic> _items = [];
  Iterable<IPlaylist> _playlists = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _load();
    });
  }

  Future<void> _load() async {
    if (widget.user.service == Service.vk) {
      _type = Service.vk;
      final id = int.parse(widget.user.id);
      await [getVkPlaylists(id), getFavoritesVk(id)].wait;
    } else if (widget.user.service == Service.youtube) {}
  }

  Widget _builder(BuildContext context, int i) {
    if (i == 0) {
      return PlaylistsCarousel(items: _playlists);
    }

    final item = _items.elementAt(i - 1).info;
    return MusicItem(
      id: item.id,
      artist: item.artist,
      title: item.title,
      img: item.coverSmall,
      type: _type,
      onPlay: () => _play(item),
    );
  }

  void _play(MusicInfo item) {
    final state = Provider.of<PlayerModel>(context, listen: false);
    state.id = item.id;
    state.service = widget.user.service;
    state.favorite = '';

    state.artist = item.artist;
    state.title = item.title;
    state.img = item.coverBig;

    Player.of(context).play(UrlSource(item.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
          onRefresh: _load,
          child: ListView.builder(
              itemCount: _items.length + 1, itemBuilder: _builder)),
    );
  }

  @override
  void onFavoritesSuccess(Iterable<MusicVk> result) {
    setState(() {
      _items = result;
    });
  }

  @override
  void onPlaylistsSuccess(Iterable<PlaylistVk> result) {
    setState(() {
      _playlists = result;
    });
  }

  @override
  void onError(String error) {
    // TODO: implement onError
  }
}
