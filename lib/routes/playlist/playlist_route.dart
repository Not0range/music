import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/music_item.dart';
import 'package:music/components/player.dart';
import 'package:music/utils/service_objects.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';

import 'playlist_presenter.dart';

class PlaylistRoute extends StatefulWidget {
  final String title;
  final Playlist playlist;

  const PlaylistRoute({super.key, required this.title, required this.playlist});

  @override
  State<StatefulWidget> createState() => _PlaylistRouteState();
}

class _PlaylistRouteState extends PlaylistContract with PlaylistPresenter {
  Service _type = Service.local;
  Iterable<IMusic> _items = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _load();
    });
  }

  Future<void> _load() async {
    switch (widget.playlist.service) {
      case Service.vk:
        await _getVk();
        _type = Service.vk;
        break;
      default:
    }
  }

  Future<void> _getVk() async {
    if (widget.playlist.favorite) {
      await getFavoritesVk();
    } else if (widget.playlist.id != null) {
      final ids = widget.playlist.id!.split('_');
      await getFromPlaylistVk(int.parse(ids[1]), int.tryParse(ids[0]));
    }
  }

  Widget _builder(BuildContext context, int i) {
    final item = _items.elementAt(i).info;
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
    state.service = widget.playlist.service;
    state.favorite = widget.playlist.favorite ? item.id : '';

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
              itemCount: _items.length, itemBuilder: _builder)),
    );
  }

  @override
  void onSuccess(Iterable<IMusic> result) {
    setState(() {
      _items = result;
    });
  }

  @override
  void onError(String error) {
    // TODO: implement onError
  }
}
