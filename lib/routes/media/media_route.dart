import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/player.dart';
import 'package:music/data/models/new_playlist_model.dart';
import 'package:music/data/models/vk/playlist_vk.dart';
import 'package:music/components/playlist_item.dart';
import 'package:music/routes/media/media_presenter.dart';
import 'package:music/utils/service_objects.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MediaRoute extends StatelessWidget {
  final bool vk;
  final bool youtube;

  const MediaRoute({super.key, this.vk = true, this.youtube = true});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<PlaylistsModel>(context);
    return MediaRouteWrapper(
      playlists: state,
      vk: vk,
      youtube: youtube,
    );
  }
}

class MediaRouteWrapper extends StatefulWidget {
  final PlaylistsModel playlists;
  final bool vk;
  final bool youtube;

  const MediaRouteWrapper(
      {super.key,
      required this.playlists,
      required this.vk,
      required this.youtube});

  @override
  State<StatefulWidget> createState() => _MediaRouteState();
}

class _MediaRouteState extends MediaContract
    with MediaPresenter, AutomaticKeepAliveClientMixin {
  late StreamSubscription _subscription;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final state = widget.playlists;
      _load(
          vk: widget.vk && state.vkPlaylists == null,
          youtube: widget.youtube); //TODO check yt playlists
      _subscription = Player.streamOf(context).listen((cmd) {
        if (cmd.type == BroadcastCommandType.followPlaylist) {
          switch (cmd.service) {
            case Service.vk:
              _load(youtube: false);
              break;
            case Service.youtube:
              _load(vk: false);
              break;
            default:
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MediaRouteWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool needVk = false;
    bool needYoutube = false;
    if (widget.vk != oldWidget.vk) {
      needVk = widget.vk && widget.playlists.vkPlaylists == null;
    }
    if (widget.youtube != oldWidget.youtube) {
      // needYoutube = widget.youtube && widget.playlists.ytPlaylists.isEmpty;
    }

    _loading = needVk || needYoutube;
    _load(vk: needVk, youtube: needYoutube);
  }

  Future<void> _load({bool vk = true, bool youtube = true}) async {
    final vkId = Provider.of<AppModel>(context, listen: false).vkProfile?.id;
    await [
      vk && vkId != null ? getVkPlaylists(vkId) : Future.value(),
      //TODO youtube playlists
    ].wait;
    if (_loading && mounted) setState(() => _loading = false);
  }

  Widget _vkBuilder(BuildContext context, int index) {
    final items = widget.playlists.vkPlaylists!;
    final i = items[index];
    final item = i.info;

    return PlaylistItem(
      leading: item.cover,
      service: Service.vk,
      title: item.title,
      type: PlaylistItemType.music,
      onTap: () => openPlaylist(
          context,
          item.title,
          Playlist(Service.vk, PlaylistType.album, item.id),
          i.permissions.edit),
      onPlay: () => _playPlaylist(PlaylistStartMode.replace, item.id),
      onAddToCurrent: () => _playPlaylist(PlaylistStartMode.add, item.id),
      onHeadQueue: () =>
          () => _playPlaylist(PlaylistStartMode.headQueue, item.id),
      onTailQueue: () =>
          () => _playPlaylist(PlaylistStartMode.tailQueue, item.id),
      onRemove: () => _removeQuestion(Service.vk, item.id),
      onEdit: i.permissions.edit ? () => _edit(Service.vk, item) : null,
    );
  }

  void _playPlaylist(PlaylistStartMode mode, [String? id]) {
    //TODO service dependency
    if (id == null) {
      getFavoritesVk(mode);
    } else {
      final ids = id.split('_');
      getFromPlaylistVk(int.parse(ids[1]), mode, ownerId: int.tryParse(ids[0]));
    }
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

  void _removeQuestion(Service service, String id) {
    showYesNoDialog(
        context, AppLocalizations.of(context).removePlaylistQuestion,
        yes: () => _remove(service, id), dangerYes: true);
  }

  void _remove(Service service, String id) {
    //TODO service dependency
    final ids = id.split('_');
    removeVkPlaylist(int.parse(ids[0]), int.parse(ids[1]));
  }

  void _edit(Service service, PlaylistInfo item) {
    openEditPlaylist(context, service,
        title: item.title, privacy: item.privacy);
  }

  Widget _loadingBuilder(BuildContext context, int _) {
    return const PlaylistItem.loading(type: PlaylistItemType.music);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: _loadingBuilder,
      );
    }

    final state = Provider.of<AppModel>(context);
    final Widget child;
    if (widget.vk || widget.youtube) {
      child = RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            const SliverPadding(padding: EdgeInsets.only(top: 10)),
            SliverToBoxAdapter(
              child: state.vkToken != null && widget.vk
                  ? PlaylistItem(
                      service: Service.vk,
                      title: AppLocalizations.of(context).myMusic,
                      type: PlaylistItemType.music,
                      onTap: () => openPlaylist(
                          context,
                          AppLocalizations.of(context).myMusic,
                          Playlist(Service.vk, PlaylistType.favorite),
                          true),
                      onPlay: () => _playPlaylist(PlaylistStartMode.replace),
                      onAddToCurrent: () =>
                          _playPlaylist(PlaylistStartMode.add),
                      onHeadQueue: () =>
                          _playPlaylist(PlaylistStartMode.headQueue),
                      onTailQueue: () =>
                          () => _playPlaylist(PlaylistStartMode.tailQueue),
                    )
                  : null,
            ),
            if (widget.vk)
              SliverList.builder(
                  itemCount: widget.playlists.vkPlaylists?.length ?? 0,
                  itemBuilder: _vkBuilder)
          ],
        ),
      );
    } else {
      child = Center(
        child: Text(
          AppLocalizations.of(context).emptyFilterPlaylists,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreatePlaylist(context),
        child: const Icon(Icons.add),
      ),
      body: child,
    );
  }

  Future<void> _openCreatePlaylist(BuildContext context) async {
    final result = await openServiceSelector(context);
    if (result == null) return;
    _createPlaylist(result);
  }

  Future<void> _createPlaylist(NewPlaylistModel model) async {
    switch (model.type) {
      case Service.vk:
        final vkId =
            Provider.of<AppModel>(context, listen: false).vkProfile?.id;
        if (vkId == null) return;

        createVkPlaylist(
            vkId, model.title, model.privacy == PrivacyType.private);
        break;
      default:
    }
  }

  @override
  void onSuccessVk(List<PlaylistVk> result) {
    widget.playlists.vkPlaylists = result;
  }

  @override
  void onItemsSuccess(List<IMusic> result, PlaylistStartMode mode,
      {bool favorite = false}) {
    if (!mounted) return;

    final List<MusicInfo> items;
    if (favorite) {
      items = result
          .map((e) => e.info.copyWith(extra: {'favorite': e.info.id}))
          .toList();
    } else {
      items = result.map((e) => e.info).toList();
    }

    final state = Provider.of<PlayerModel>(context, listen: false);
    switch (mode) {
      case PlaylistStartMode.add:
        final empty = state.list.isEmpty;
        state.insertAll(items);
        if (empty) {
          final item = items[0];
          state.setItem(item, favorite: favorite ? item.id : '');
          state.index = 0;
          Player.of(context).setSource(UrlSource(item.url));
        }
        break;
      case PlaylistStartMode.replace:
        state.list = items;

        final item = items[0];
        state.setItem(item, favorite: favorite ? item.id : '');
        state.index = 0;
        Player.of(context).play(UrlSource(item.url));
        break;
      case PlaylistStartMode.headQueue:
        _addToQueue(items, true);
        break;
      case PlaylistStartMode.tailQueue:
        _addToQueue(items, false);
        break;
    }
  }

  @override
  void onError(String error) {
    // TODO: implement onError
  }

  @override
  bool get wantKeepAlive => true;
}
