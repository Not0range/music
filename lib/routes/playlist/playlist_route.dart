import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/loading_container.dart';
import 'package:music/components/music_item.dart';
import 'package:music/components/player.dart';
import 'package:music/utils/service_objects.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/styles.dart';
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
  List<IMusic> _items = [];
  bool _loading = true;

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
    if (widget.playlist.type == PlaylistType.favorite) {
      await getFavoritesVk();
    } else if (widget.playlist.id != null) {
      if (widget.playlist.type == PlaylistType.album) {
        final ids = widget.playlist.id!.split('_');
        await getFromPlaylistVk(int.parse(ids[1]), int.tryParse(ids[0]));
      } else {
        await getRelatedVk(widget.playlist.id!);
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  Widget _builder(BuildContext context, int i) {
    final item = _items[i].info;
    final favorite = widget.playlist.type == PlaylistType.favorite;
    return MusicItem(
      id: item.id,
      artist: item.artist,
      title: item.title,
      img: item.coverSmall,
      type: _type,
      onPlay: () => _play(item, i),
      favorite: favorite,
      onToggleFavorite: (id) => _favoriteVk(!favorite, id),
      addToQueue: (h) => _addToQueue(item, h),
    );
  }

  Widget _loadingBuilder(BuildContext context, int _) {
    return const MusicItem.loading();
  }

  void _play(MusicInfo item, int index) {
    final state = Provider.of<PlayerModel>(context, listen: false);
    if (state.id == item.id && state.service == _type) {
      //TODO open player
      return;
    }
    //TODO if same playlist change current index

    state.setItem(item,
        favorite: widget.playlist.type == PlaylistType.favorite ? item.id : '');

    if (widget.playlist.type == PlaylistType.favorite) {
      state.list = _items
          .map((e) => e.info.copyWith(extra: {'favorite': e.info.id}))
          .toList();
    } else {
      state.list = _items.map((e) => e.info).toList();
    }
    state.index = index;
    Player.of(context).play(UrlSource(item.url));
  }

  void _addToQueue(MusicInfo item, bool head) {
    if (widget.playlist.type == PlaylistType.favorite) {
      item = item.copyWith(extra: {'favorite': item.id});
    }

    final state = Provider.of<PlayerModel>(context, listen: false);
    final bool start;
    if (head) {
      start = state.headQueue(item);
    } else {
      start = state.tailQueue(item);
    }
    if (start) {
      Player.of(context).setSourceUrl(item.url);
    }
  }

  void _favoriteVk(bool add, String id) {
    final ids = id.split('_').map((e) => int.parse(e)).toList();
    if (add) {
      addVk(ids[0], ids[1]);
    } else {
      removeVk(ids[0], ids[1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (_loading) {
      child = ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: _loadingBuilder);
    } else {
      child = RefreshIndicator(
          onRefresh: _load,
          child: ListView.builder(
              itemCount: _items.length, itemBuilder: _builder));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Shimmer(
          gradient: Theme.of(context).brightness == Brightness.light
              ? shimmerLigth
              : shimmerDark,
          child: child),
    );
  }

  @override
  void onSuccess(List<IMusic> result) {
    setState(() {
      _items = result;
    });
  }

  @override
  void onFavoriteSuccess(bool added) {
    if (widget.playlist.type == PlaylistType.favorite) _load();
    //TODO: implement onFavoriteSuccess
  }

  @override
  void onError(String error) {
    // TODO: implement onError
  }
}
