import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/loading_container.dart';
import 'package:music/components/music_item.dart';
import 'package:music/components/player.dart';
import 'package:music/data/models/vk/music_vk.dart';
import 'package:music/data/models/vk/playlist_vk.dart';
import 'package:music/routes/user/components/playlists_carousel.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/service_objects.dart';
import 'package:music/utils/styles.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  List<IMusic> _items = [];
  List<IPlaylist> _playlists = [];
  bool _loading = true;

  List<int>? _selected;

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
    setState(() => _loading = false);
  }

  Widget _builder(BuildContext context, int i) {
    final item = _items[i].info;
    return MusicItem(
      id: item.id,
      artist: item.artist,
      title: item.title,
      img: item.coverSmall,
      type: _type,
      onPlay:
          _selected == null ? () => _play(item, i) : () => _toggleSelected(i),
      addToQueue: (h) => _addToQueue(item, h),
      onToggleFavorite: _favoriteVk,
      addToPlaylist: () => _addToVkPlaylist(item.id),
      selected: _selected?.contains(i) ?? false,
    );
  }

  Widget _loadingBuilder(BuildContext context, int i) {
    return const MusicItem.loading();
  }

  void _play(MusicInfo item, int index) {
    final state = Provider.of<PlayerModel>(context, listen: false);
    if (state.id == item.id && state.service == widget.user.service) {
      //TODO open player
      return;
    }
    //TODO if same playlist change current index

    state.setItem(item);

    state.list = _items.map((e) => e.info).toList();
    state.index = index;
    Player.of(context).play(UrlSource(item.url));
  }

  void _addToQueue(MusicInfo item, bool head) {
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

  void _addToVkPlaylist(String id) {
    showAddToPlaylistDialog(context, id, widget.user.service);
  }

  void _favoriteVk(String id) {
    final ids = id.split('_').map((e) => int.parse(e)).toList();
    addVk(ids[0], ids[1]);
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

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return PopScope(
      canPop: _selected == null,
      onPopInvoked: _willPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_selected == null ? widget.title : locale.selectTracks),
          actions: [
            if (_selected == null)
              IconButton(
                  onPressed: () => setState(() => _selected = []),
                  icon: const Icon(Icons.check_box_outlined))
            else
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),
        body: Shimmer(
            gradient: Theme.of(context).brightness == Brightness.light
                ? shimmerLigth
                : shimmerDark,
            child: RefreshIndicator(
                onRefresh: _load,
                child: CustomScrollView(
                  physics:
                      _loading ? const NeverScrollableScrollPhysics() : null,
                  slivers: [
                    SliverToBoxAdapter(
                      child: PlaylistsCarousel(
                        items: _playlists,
                        loading: _loading,
                      ),
                    ),
                    SliverList.builder(
                        itemCount: _loading ? null : _items.length,
                        itemBuilder: _loading ? _loadingBuilder : _builder),
                  ],
                ))),
      ),
    );
  }

  @override
  void onFavoritesSuccess(List<MusicVk> result) {
    setState(() {
      _items = result;
    });
  }

  @override
  void onPlaylistsSuccess(List<PlaylistVk> result) {
    setState(() {
      _playlists = result;
    });
  }

  @override
  void onFavoriteSuccess() {
    // TODO: implement onFavoriteSuccess
  }

  @override
  void onError(String error) {
    // TODO: implement onError
  }
}
