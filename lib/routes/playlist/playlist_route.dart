import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/loading_container.dart';
import 'package:music/components/music_item.dart';
import 'package:music/components/player.dart';
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
    });
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
      addToQueue: (h) => _addToQueue(item, h),
      addToPlaylist: () => _addToVkPlaylist(item.id),
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

  void _play(MusicInfo item, int index) {
    final state = Provider.of<PlayerModel>(context, listen: false);
    if (state.id == item.id && state.service == widget.playlist.service) {
      //TODO open player
      return;
    }
    //TODO if same playlist change current index

    state.setItem(item,
        favorite: _type == PlaylistType.favorite ? item.id : '');

    if (_type == PlaylistType.favorite) {
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
    if (_type == PlaylistType.favorite) {
      item = item.copyWith(extra: {'favorite': item.id}); //TODO yt
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

  Future<void> _addToVkPlaylist(String id) async {
    final result =
        await showAddToPlaylistDialog(context, id, widget.playlist.service);
    if (result == widget.playlist.id) _load();
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

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    final Widget child;
    if (_loading) {
      child = ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: _loadingBuilder);
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
                  onPressed: () {}, icon: const Icon(Icons.check_box_outlined)),
            if (_selected != null)
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),
        body: Shimmer(
            gradient: Theme.of(context).brightness == Brightness.light
                ? shimmerLigth
                : shimmerDark,
            child: child),
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
  void onFavoriteSuccess(bool added) {
    if (_type == PlaylistType.favorite) _load();
    //TODO: implement onFavoriteSuccess
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
