import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/net_image.dart';
import 'package:music/components/player.dart';
import 'package:music/components/playing_icon.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

const _itemCount = 20;

class ResultCategory extends StatelessWidget {
  final String title;
  final Iterable<IMusic> items;
  final Service type;
  final bool forwardTitle;

  const ResultCategory({
    super.key,
    required this.title,
    required this.items,
    required this.type,
    this.forwardTitle = true,
  });

  Widget _builder(BuildContext context, int index) {
    final item1 = items.elementAtOrNull(index * 2)?.info;
    final item2 = items.elementAtOrNull(index * 2 + 1)?.info;

    return Column(
      children: [
        item1 != null
            ? ResultItem(
                info: item1,
                type: type,
              )
            : const SizedBox.shrink(),
        item2 != null
            ? ResultItem(
                info: item2,
                type: type,
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 200,
      child: Column(
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
      ),
    );
  }
}

class ResultItem extends StatelessWidget {
  final MusicInfo info;
  final Service type;

  const ResultItem({super.key, required this.info, required this.type});

  void _onTap(BuildContext context) {
    final state = Provider.of<PlayerModel>(context, listen: false);
    state.id = info.id;
    state.service = type;
    state.favorite = '';

    state.artist = info.artist;
    state.title = info.title;
    state.img = info.coverBig;

    Player.of(context).play(UrlSource(info.url));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: InkWell(
        onTap: () => _onTap(context),
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
      ),
    );
  }
}
