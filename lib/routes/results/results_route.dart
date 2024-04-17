import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/music_item.dart';
import 'package:music/components/player.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'result_presenter.dart';

class ResultRoute extends StatefulWidget {
  final List<IMusic> items;
  final Service type;
  final String? title;

  const ResultRoute(
      {super.key, required this.items, required this.type, this.title});

  @override
  State<StatefulWidget> createState() => _ResultRouteState();
}

class _ResultRouteState extends ResultContract with ResultPresenter {
  List<int>? _selected;

  Widget _builder(BuildContext context, int i) {
    final item = widget.items[i].info;
    return MusicItem(
      id: item.id,
      artist: item.artist,
      title: item.title,
      img: item.coverSmall,
      type: widget.type,
      onPlay:
          _selected == null ? () => _play(item, i) : () => _toggleSelected(i),
      addToQueue: (h) => _addToQueue([item], h),
      addToPlaylist: () => _addToVkPlaylist(context, item.id),
      onToggleFavorite: _favoriteVk,
      selected: _selected?.contains(i) ?? false,
    );
  }

  void _play(MusicInfo item, int index) {
    final state = Provider.of<PlayerModel>(context, listen: false);
    if (state.id == item.id && state.service == widget.type) {
      //TODO open player
      return;
    }
    //TODO if same playlist change current index

    state.setItem(item);

    state.list = widget.items.map((e) => e.info).toList();
    state.index = index;
    state.fromQueue = false;
    Player.of(context).play(UrlSource(item.url));
  }

  void _playMultiple(Iterable<MusicInfo> items) {
    final state = Provider.of<PlayerModel>(context, listen: false);
    state.setItem(items.first);

    state.list = items.toList();
    state.fromQueue = false;
    Player.of(context).play(UrlSource(items.first.url));
  }

  void _addToQueue(Iterable<MusicInfo> items, bool head) {
    final state = Provider.of<PlayerModel>(context, listen: false);
    final bool start;
    if (head) {
      start = state.headQueue(items);
    } else {
      start = state.tailQueue(items);
    }
    if (start) {
      Player.of(context).setSourceUrl(items.first.url);
    }
  }

  void _favoriteVk(String id) {
    final ids = id.split('_').map((e) => int.parse(e)).toList();
    addVk(ids[0], ids[1]);
  }

  void _addToVkPlaylist(BuildContext context, String id) {
    showAddToPlaylistDialog(context, id, widget.type);
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
    if (willPop) return;

    setState(() => _selected = null);
  }

  void _openMultipleMenu() {
    openItemMenu(
      context,
      null,
      onPlay: () => _playMultiple(_selected!.map((e) => widget.items[e].info)),
      onHeadQueue: () =>
          _addToQueue(_selected!.map((e) => widget.items[e].info), true),
      onTailQueue: () =>
          _addToQueue(_selected!.map((e) => widget.items[e].info), false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return PopScope(
      canPop: _selected == null,
      onPopInvoked: _willPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_selected == null
              ? widget.title ?? locale.searchResult
              : locale.selectTracks),
          actions: [
            if (_selected == null)
              IconButton(
                  onPressed: () => setState(() => _selected = []),
                  icon: const Icon(Icons.check_box_outlined))
            else
              IconButton(
                  onPressed: _openMultipleMenu,
                  icon: const Icon(Icons.more_vert)),
          ],
        ),
        body: ListView.builder(
            itemCount: widget.items.length, itemBuilder: _builder),
      ),
    );
  }

  @override
  void onFavoriteSuccess() {
    // TODO: implement onFavoriteSuccess
  }
}
