import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/net_image.dart';
import 'package:music/data/models/vk/playlist_vk.dart';
import 'package:music/components/playlist_item.dart';
import 'package:music/routes/media/media_presenter.dart';
import 'package:music/utils/service_objects.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MediaRoute extends StatefulWidget {
  const MediaRoute({super.key});

  @override
  State<StatefulWidget> createState() => _MediaRouteState();
}

class _MediaRouteState extends MediaContract
    with MediaPresenter, AutomaticKeepAliveClientMixin {
  Iterable<IPlaylist> _playlistsVk = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _load();
    });
  }

  Future<void> _load() async {
    final vkId = Provider.of<AppModel>(context, listen: false).vkProfile?.id;
    if (vkId != null) await getVkPlaylists(vkId);
  }

  Widget _builder(BuildContext context, int index) {
    if (index == 0) {
      final state = Provider.of<AppModel>(context, listen: false);
      if (state.vkToken == null) return const SizedBox.shrink();

      return PlaylistItem(
        leading: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            Icons.favorite,
            size: 36,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        type: Service.vk,
        title: AppLocalizations.of(context).myMusic,
        onTap: () => openPlaylist(context, AppLocalizations.of(context).myMusic,
            Playlist(Service.vk, true)),
      );
    }

    final item = _playlistsVk.elementAt(index - 1).info;
    return PlaylistItem(
      leading: Container(
        height: 46,
        width: 46,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        child: NetImage(
          img: item.cover,
          placeholder: const Icon(Icons.library_music_outlined),
        ),
      ),
      type: Service.vk,
      title: item.title,
      onTap: () => openPlaylist(
          context, item.title, Playlist(Service.vk, false, item.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _load,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: ListView.builder(
          itemCount: _playlistsVk.length + 1,
          itemBuilder: _builder,
        ),
      ),
    );
  }

  @override
  void onSuccessVk(Iterable<PlaylistVk> result) {
    setState(() {
      _playlistsVk = result;
    });
  }

  @override
  void onError(String error) {
    // TODO: implement onError
  }

  @override
  bool get wantKeepAlive => true;
}
