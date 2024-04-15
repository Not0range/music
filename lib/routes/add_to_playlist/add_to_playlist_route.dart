import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/playlist_item.dart';
import 'package:music/data/models/vk/playlist_vk.dart';
import 'package:music/utils/service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';

import 'add_to_playlist_presenter.dart';

class AddToPlaylistRoute extends StatelessWidget {
  final String id;
  final Service service;

  const AddToPlaylistRoute(
      {super.key, required this.id, required this.service});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<PlaylistsModel>(context);
    final List<IPlaylist>? items;
    switch (service) {
      case Service.vk:
        items = state.vkPlaylists;
        break;
      default:
        items = null;
    }
    return AddToPlaylistRouteWrapper(
      id: id,
      service: service,
      items: items,
      setVkItems: (i) => state.vkPlaylists = i,
    ); //TODO setting yt playlists
  }
}

class AddToPlaylistRouteWrapper extends StatefulWidget {
  final String id;
  final Service service;
  final List<IPlaylist>? items;
  final Proc1<List<PlaylistVk>>? setVkItems;
  final Proc1<List<PlaylistVk>>? setYtItems;

  const AddToPlaylistRouteWrapper(
      {super.key,
      required this.id,
      required this.service,
      this.items,
      this.setVkItems,
      this.setYtItems});

  @override
  State<StatefulWidget> createState() => _AddToPlaylistRouteWrapperState();
}

class _AddToPlaylistRouteWrapperState extends AddToPlaylistContract
    with AddToPlaylistPresenter {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (widget.items != null) return;
      _load();
    });
  }

  Future<void> _load() async {
    switch (widget.service) {
      case Service.vk:
        final vkId =
            Provider.of<AppModel>(context, listen: false).vkProfile?.id;
        if (vkId != null) await getVkPlaylists(vkId);
        break;
      default:
    }
  }

  Widget _builder(BuildContext context, ScrollController controller) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(AppLocalizations.of(context).playlists),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh))
        ],
      ),
      body: ListView.builder(
          controller: controller,
          itemCount: widget.items?.length,
          itemBuilder: widget.items != null ? _itemBuilder : _loadingBuilder),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final item = widget.items![index].info;

    return PlaylistItem(
      leading: item.cover,
      service: widget.service,
      title: item.title,
      type: PlaylistItemType.music,
      onTap: () => _addToPlaylist(item),
    );
  }

  Widget _loadingBuilder(BuildContext context, int _) {
    return const PlaylistItem.loading(type: PlaylistItemType.music);
  }

  void _addToPlaylist(PlaylistInfo item) {
    //TODO lock UI
    switch (widget.service) {
      case Service.vk:
        final ids = item.id.split('_').map((e) => int.parse(e)).toList();
        addToVkPlaylist(ids[0], ids[1], widget.id);
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false, snap: true, minChildSize: 0.5, builder: _builder);
  }

  @override
  void onSuccessVk(List<PlaylistVk> result) {
    widget.setVkItems?.call(result);
  }

  @override
  void onSuccessAdded(String playlistId) {
    if (!mounted) return;
    Navigator.pop(context, playlistId);
  }
}
