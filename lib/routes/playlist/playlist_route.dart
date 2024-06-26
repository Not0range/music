import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:music/app_model.dart';
import 'package:music/components/loading_container.dart';
import 'package:music/components/music_item.dart';
import 'package:music/components/player.dart';
import 'package:music/utils/player_helper.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/service_objects.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/styles.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'playlist_presenter.dart';

class PlaylistRoute extends StatefulWidget {
  final String title;
  final Playlist playlist;
  final bool editable;

  const PlaylistRoute(
      {super.key,
      required this.title,
      required this.playlist,
      this.editable = false});

  @override
  State<StatefulWidget> createState() => _PlaylistRouteState();
}

class _PlaylistRouteState extends PlaylistContract with PlaylistPresenter {
  late final StreamSubscription _subscription;

  List<IMusic> _items = [];
  bool _loading = true;

  bool _changingOrder = false;
  bool _needCommit = false;
  bool _editProceed = false;

  List<int>? _selected;

  PlaylistType get _type => widget.playlist.type;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _load();
      if (widget.playlist.type == PlaylistType.favorite) {
        _subscription = PlayerCommand.streamOf(context).listen((cmd) {
          if (cmd.type == BroadcastCommandType.changeFavorites &&
              cmd.service == widget.playlist.service) {
            _load();
          }
        });
      } else {
        _subscription = PlayerCommand.streamOf(context).listen((cmd) {
          if (cmd.type == BroadcastCommandType.addToPlaylist &&
              cmd.service == widget.playlist.service &&
              cmd.params?['playlistId'] == widget.playlist.id) {
            _load();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    switch (widget.playlist.service) {
      case Service.vk:
        await _getVk();
        break;
      default:
    }
  }

  Future<void> _getVk() async {
    if (_type == PlaylistType.favorite) {
      await getFavoritesVk();
    } else if (widget.playlist.id != null) {
      if (_type == PlaylistType.album) {
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
    final favorite = _type == PlaylistType.favorite;
    return MusicItem(
      key: Key(item.id),
      id: item.id,
      artist: item.artist,
      title: item.title,
      img: item.coverSmall,
      type: item.type,
      onPlay:
          _selected == null ? () => _play(item, i) : () => _toggleSelected(i),
      favorite: favorite,
      onToggleFavorite: (id) => _favoriteVk(!favorite, id),
      addToQueue: (h) => _addToQueue([item], h),
      addToPlaylist: () =>
          showAddToPlaylistDialog(context, item.id, widget.playlist.service),
      removeFromPlaylist: widget.editable && _type == PlaylistType.album
          ? () => _removeItem(i)
          : null,
      reorderableIndex: _changingOrder ? i : null,
      selected: _selected?.contains(i) ?? false,
    );
  }

  Widget _loadingBuilder(BuildContext context, int _) {
    return const MusicItem.loading();
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
    _needCommit = true;
  }

  Future<void> _play(MusicInfo item, int index) async {
    final state = Provider.of<PlayerModel>(context, listen: false);
    if (state.id == item.id && state.service == widget.playlist.service) {
      //TODO open player
      return;
    }
    //TODO if same playlist change current index

    if (_type == PlaylistType.favorite) {
      state.list = _items
          .map((e) => e.info.copyWith(extra: {'favorite': e.info.id}))
          .toList();
    } else {
      state.list = _items.map((e) => e.info).toList();
    }
    state.index = index;
    state.fromQueue = false;
    state.setItem(item,
        favorite: _type == PlaylistType.favorite ? item.id : '');

    await PlayerHelper.instance.play(item.url, item.toJson());

    PlayerHelper.instance
        .setBookmark(_type == PlaylistType.favorite); //TODO check services

    if (item.coverBig == null) return;
    final file = await DefaultCacheManager().getSingleFile(item.coverBig!);
    await PlayerHelper.instance.setMetadataCover(file.path);
  }

  void _playMultiple(Iterable<MusicInfo> items) {
    final state = Provider.of<PlayerModel>(context, listen: false);
    state.setItem(items.first);

    if (_type == PlaylistType.favorite) {
      items = items.map((e) => e.copyWith(extra: {'favorite': e.id})).toList();
    }

    state.list = items.toList();
    state.fromQueue = false;

    final item = items.first;
    PlayerHelper.instance.play(item.url, item.toJson());

    PlayerHelper.instance
        .setBookmark(_type == PlaylistType.favorite); //TODO check services

    if (item.coverBig == null) return;
    DefaultCacheManager()
        .getSingleFile(item.coverBig!)
        .then((file) => PlayerHelper.instance.setMetadataCover(file.path));
  }

  void _addToQueue(Iterable<MusicInfo> items, bool head) {
    if (_type == PlaylistType.favorite) {
      items = items.map((e) => e.copyWith(extra: {'favorite': e.id})); //TODO yt
    }

    final state = Provider.of<PlayerModel>(context, listen: false);
    final bool start;
    if (head) {
      start = state.headQueue(items);
    } else {
      start = state.tailQueue(items);
    }
    if (start) {
      final item = items.first;
      PlayerHelper.instance.setSource(item.url, item.toJson());

      PlayerHelper.instance
          .setBookmark(_type == PlaylistType.favorite); //TODO check services

      if (item.coverBig == null) return;
      DefaultCacheManager()
          .getSingleFile(item.coverBig!)
          .then((file) => PlayerHelper.instance.setMetadataCover(file.path));
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

  void _swap(int oldIndex, int newIndex) {
    _needCommit = true;
    if (oldIndex < newIndex) newIndex -= 1;

    final item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);

    switch (widget.playlist.service) {
      case Service.vk:
        if (_type == PlaylistType.favorite) {
          reorderVk(item.info.id.split('_')[1],
              prevId: newIndex == _items.length - 1
                  ? _items[_items.length - 2].info.id.split('_')[1]
                  : null,
              nextId: newIndex < _items.length - 1
                  ? _items[newIndex + 1].info.id.split('_')[1]
                  : null);
        }
        break;
      default:
    }
  }

  void _toggleSelected(int i) {
    if (_selected == null) return;

    if (_selected!.contains(i)) {
      _selected?.remove(i);
    } else {
      _selected?.add(i);
    }
    setState(() {});
  }

  void _willPop(bool willPop) {
    if (willPop) {
      if (!_editProceed && _needCommit) _saveChanges();
      return;
    }

    if (_selected != null) {
      setState(() => _selected = null);
      return;
    }

    if (_editProceed) return;

    if (_type == PlaylistType.favorite) {
      setState(() => _changingOrder = false);
      return;
    }

    if (!_needCommit) return;
    _editProceed = true;
    _saveChanges();
  }

  void _saveChanges() {
    switch (widget.playlist.service) {
      case Service.vk:
        final ids =
            widget.playlist.id!.split('_').map((e) => int.parse(e)).toList();
        editPlaylistVk(ids[0], ids[1], _items.map((e) => e.info.id).toList());
        break;
      default:
    }
  }

  void _openMultipleMenu() {
    openItemMenu(
      context,
      null,
      onPlay: () => _playMultiple(_selected!.map((e) => _items[e].info)),
      onHeadQueue: () =>
          _addToQueue(_selected!.map((e) => _items[e].info), true),
      onTailQueue: () =>
          _addToQueue(_selected!.map((e) => _items[e].info), false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    final Widget child;
    if (_loading) {
      child = Shimmer(
        gradient: Theme.of(context).brightness == Brightness.light
            ? shimmerLigth
            : shimmerDark,
        child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: _loadingBuilder),
      );
    } else {
      child = RefreshIndicator(
          onRefresh: _load,
          child: ReorderableListView.builder(
              itemCount: _items.length,
              onReorder: _swap,
              itemBuilder: _builder));
    }
    return PopScope(
      canPop: !_editProceed && !_changingOrder && _selected == null,
      onPopInvoked: _willPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_selected == null ? widget.title : locale.selectTracks),
          actions: [
            //TODO if owned playlist
            if (!_changingOrder && widget.editable && _selected == null)
              MenuAnchor(
                menuChildren: [
                  MenuItemButton(
                      onPressed: () => setState(() => _changingOrder = true),
                      leadingIcon: const Icon(Icons.swap_vert),
                      child: Text(locale.changeOrder)),
                  MenuItemButton(
                      onPressed: () => setState(() => _selected = []),
                      leadingIcon: const Icon(Icons.check_box_outlined),
                      child: Text(locale.selectTracks)),
                ],
                builder: (ctx, c, _) => IconButton(
                    onPressed: c.open, icon: const Icon(Icons.more_vert)),
              ),
            if (!_changingOrder && !widget.editable && _selected == null)
              IconButton(
                  onPressed: () => setState(() => _selected = []),
                  icon: const Icon(Icons.check_box_outlined)),
            if (_selected != null)
              IconButton(
                  onPressed: _openMultipleMenu,
                  icon: const Icon(Icons.more_vert)),
          ],
        ),
        body: child,
      ),
    );
  }

  @override
  void onSuccess(List<IMusic> result) {
    setState(() {
      _items = result;
    });
  }

  @override
  void onFavoriteSuccess(Service service, bool added) {
    PlayerCommand.sendCommand(context,
        BroadcastCommand(BroadcastCommandType.changeFavorites, service));
  }

  @override
  void onError(String error) {
    // TODO: implement onError
  }

  @override
  void onEditSuccess() {
    setState(() {
      _changingOrder = false;
      _needCommit = false;
      _editProceed = false;
    });
  }
}
