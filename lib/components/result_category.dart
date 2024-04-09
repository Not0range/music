import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/loading_container.dart';
import 'package:music/components/net_image.dart';
import 'package:music/components/player.dart';
import 'package:music/components/playing_icon.dart';
import 'package:music/utils/constants.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/service_objects.dart';
import 'package:music/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

const _itemCount = 20;

class ResultCategory extends StatelessWidget {
  final String title;
  final List<IMusic> items;
  final Service type;
  final bool forwardTitle;
  final Proc1<String>? addToFavorite;
  final bool loading;

  const ResultCategory({
    super.key,
    required this.title,
    required this.items,
    required this.type,
    this.forwardTitle = true,
    this.addToFavorite,
  }) : loading = false;

  ResultCategory.loading({super.key})
      : title = '',
        items = [],
        type = Service.local,
        forwardTitle = false,
        addToFavorite = null,
        loading = true;

  void _play(BuildContext context, MusicInfo item, int index) {
    final state = Provider.of<PlayerModel>(context, listen: false);
    if (state.id == item.id && state.service == type) {
      //TODO open player
      return;
    }
    //TODO if same playlist change current index

    state.setItem(item);

    state.list = items.map((e) => e.info).toList();
    state.index = index;
    Player.of(context).play(UrlSource(item.url));
  }

  void _addToQueue(BuildContext context, MusicInfo item, bool head) {
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

  void _openMenu(BuildContext context, MusicInfo info, int index) {
    openMenu(context, info,
        onPlay: () => _play(context, info, index),
        onHeadQueue: () => _addToQueue(context, info, true),
        onTailQueue: () => _addToQueue(context, info, false),
        onToggleMyMusic: addToFavorite != null && type != Service.youtube
            ? () => addToFavorite?.call(info.id)
            : null,
        onToggleLike: addToFavorite != null && type == Service.youtube
            ? () => addToFavorite?.call(info.id)
            : null,
        onSearchRelated: () => _searchRelated(context, info),
        onShare: () => _share(info));
  }

  void _searchRelated(BuildContext context, MusicInfo info) {
    openPlaylist(context, AppLocalizations.of(context).relatedTracks,
        Playlist(type, PlaylistType.related, info.id));
  }

  void _share(MusicInfo info) {
    switch (type) {
      case Service.vk:
        Share.share('$vkShareBase${info.id}');
        break;
      default:
    }
  }

  Widget _builder(BuildContext context, int index) {
    final item1 = items.elementAtOrNull(index * 2)?.info;
    final item2 = items.elementAtOrNull(index * 2 + 1)?.info;

    return Column(
      children: [
        item1 != null
            ? ResultItem(
                info: item1,
                type: type,
                addToFavorite: addToFavorite,
                onTap: () => _play(context, item1, index * 2),
                onLongTap: () => _openMenu(context, item1, index * 2),
              )
            : const SizedBox.shrink(),
        item2 != null
            ? ResultItem(
                info: item2,
                type: type,
                addToFavorite: addToFavorite,
                onTap: () => _play(context, item2, index * 2 + 1),
                onLongTap: () => _openMenu(context, item2, index * 2 + 1),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _loadingBuilder(BuildContext context, int _) {
    return Column(
      children: [ResultItem.loading(), ResultItem.loading()],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !loading) return const SizedBox.shrink();

    final Widget child;
    if (loading) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 10, 5),
            child: LoadingContainer(
              width: MediaQuery.sizeOf(context).width * 0.7,
              child: Text(
                '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
                padEnds: false,
                physics: const NeverScrollableScrollPhysics(),
                controller: PageController(viewportFraction: 0.8),
                itemCount: 2,
                itemBuilder: _loadingBuilder),
          )
        ],
      );
    } else {
      child = Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 10, 5),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                )),
                TextButton(
                    onPressed: () => openResults(
                        context, type, items, forwardTitle ? title : null),
                    child: Text(AppLocalizations.of(context).more))
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
                padEnds: false,
                controller: PageController(viewportFraction: 0.8),
                itemCount: (math.min(_itemCount, items.length) / 2).ceil(),
                itemBuilder: _builder),
          )
        ],
      );
    }

    return SizedBox(
      height: 200,
      child: child,
    );
  }
}

class ResultItem extends StatelessWidget {
  final MusicInfo info;
  final Service type;
  final Proc1<String>? addToFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onLongTap;
  final bool loading;

  const ResultItem(
      {super.key,
      required this.info,
      required this.type,
      this.addToFavorite,
      this.onTap,
      this.onLongTap})
      : loading = false;

  ResultItem.loading({super.key})
      : info = MusicInfo.empty(),
        type = Service.local,
        addToFavorite = null,
        onTap = null,
        onLongTap = null,
        loading = true;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (loading) {
      child = Row(
        children: [
          const AspectRatio(
            aspectRatio: 1,
            child: LoadingContainer(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LoadingContainer(
                    bottom: 5,
                    child: Text(
                      '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  LoadingContainer(
                    child: Text(
                      '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      );
    } else {
      child = InkWell(
        onTap: onTap,
        onLongPress: onLongTap,
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  NetImage(
                    img: info.coverSmall,
                    placeholder: const Icon(Icons.music_note),
                  ),
                  Consumer<PlayerModel>(
                      builder: (ctx, state, _) => Visibility(
                          visible: state.service == type && state.id == info.id,
                          child: PlayingIcon(animated: state.playing)))
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      info.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      );
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: child,
    );
  }
}
