import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/music_item.dart';
import 'package:music/components/player.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResultRoute extends StatelessWidget {
  final List<IMusic> items;
  final Service type;
  final String? title;

  const ResultRoute(
      {super.key, required this.items, required this.type, this.title});

  Widget _builder(BuildContext context, int i) {
    final item = items[i].info;
    return MusicItem(
      id: item.id,
      artist: item.artist,
      title: item.title,
      img: item.coverSmall,
      type: type,
      onPlay: () => _play(context, item, i),
      addToQueue: (h) => _addToQueue(context, item, h),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(title ?? AppLocalizations.of(context).searchResult)),
      body: ListView.builder(itemCount: items.length, itemBuilder: _builder),
    );
  }
}
