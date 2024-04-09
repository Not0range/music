import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
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
  List<IPlaylist> _playlistsVk = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _load();
    });
  }

  Future<void> _load() async {
    final vkId = Provider.of<AppModel>(context, listen: false).vkProfile?.id;
    await [vkId != null ? getVkPlaylists(vkId) : Future.value()].wait;
    if (mounted) setState(() => _loading = false);
  }

  Widget _builder(BuildContext context, int index) {
    if (index == 0) {
      final state = Provider.of<AppModel>(context, listen: false);
      if (state.vkToken == null) return const SizedBox.shrink();

      return PlaylistItem(
        service: Service.vk,
        title: AppLocalizations.of(context).myMusic,
        type: PlaylistItemType.music,
        onTap: () => openPlaylist(context, AppLocalizations.of(context).myMusic,
            Playlist(Service.vk, PlaylistType.favorite)),
      );
    }

    final item = _playlistsVk[index - 1].info;
    return PlaylistItem(
      leading: item.cover,
      service: Service.vk,
      title: item.title,
      type: PlaylistItemType.music,
      onTap: () => openPlaylist(context, item.title,
          Playlist(Service.vk, PlaylistType.album, item.id)),
    );
  }

  Widget _laodingBuilder(BuildContext context, int _) {
    return const PlaylistItem.loading(type: PlaylistItemType.music);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: _laodingBuilder,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: _playlistsVk.length + 1,
        itemBuilder: _builder,
      ),
    );
  }

  @override
  void onSuccessVk(List<PlaylistVk> result) {
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
