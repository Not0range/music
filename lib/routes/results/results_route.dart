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
  final Iterable<IMusic> items;
  final Service type;
  final String? title;

  const ResultRoute(
      {super.key, required this.items, required this.type, this.title});

  Widget _builder(BuildContext context, int i) {
    final item = items.elementAt(i).info;
    return MusicItem(
      id: item.id,
      artist: item.artist,
      title: item.title,
      img: item.coverSmall,
      type: type,
      onPlay: () => _play(context, item),
    );
  }

  void _play(BuildContext context, MusicInfo item) {
    final state = Provider.of<PlayerModel>(context, listen: false);
    state.id = item.id;
    state.service = type;
    state.favorite = '';

    state.artist = item.artist;
    state.title = item.title;
    state.img = item.coverBig;

    Player.of(context).play(UrlSource(item.url));
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
