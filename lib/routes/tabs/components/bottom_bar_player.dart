import 'package:flutter/material.dart';
import 'package:music/routes/tabs/components/mini_player.dart';
import 'package:music/routes/player/player_route.dart';
import 'package:music/utils/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:music/utils/utils.dart';

class BottomBarPlayer extends StatefulWidget {
  final double topInset;
  final TabController controller;
  final Proc1<int>? onTabChanged;

  const BottomBarPlayer(
      {super.key,
      this.topInset = 0,
      required this.controller,
      this.onTabChanged});

  @override
  State<StatefulWidget> createState() => _BottomBarPlayerState();
}

class _BottomBarPlayerState extends State<BottomBarPlayer> {
  double _position = 0;

  void _setPosition(double value) {
    setState(() => _position = value);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            MiniPlayer(onChangePosition: _setPosition),
            SizedBox(
              height: toolBarHeight,
              child: TabBar(
                  onTap: widget.onTabChanged,
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.home),
                      text: AppLocalizations.of(context).home,
                      iconMargin: const EdgeInsets.symmetric(vertical: 5),
                    ),
                    Tab(
                      icon: const Icon(Icons.search),
                      text: AppLocalizations.of(context).search,
                      iconMargin: const EdgeInsets.symmetric(vertical: 5),
                    ),
                    Tab(
                      icon: const Icon(Icons.library_music_outlined),
                      text: AppLocalizations.of(context).mediaLib,
                      iconMargin: const EdgeInsets.symmetric(vertical: 5),
                    ),
                  ],
                  controller: widget.controller),
            ),
          ],
        ),
        PlayerRoute(
          position: _position,
          topInset: widget.topInset,
          onClosed: () => _setPosition(0),
        ),
      ],
    );
  }
}
