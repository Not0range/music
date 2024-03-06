import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music/components/mini_player.dart';
import 'package:music/routes/home/home_route.dart';
import 'package:music/routes/media/media_route.dart';
import 'package:music/routes/player/player_route.dart';
import 'package:music/routes/search/search_route.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:music/routes/settings/settings_route.dart';
import 'package:music/utils/constants.dart';
import 'package:music/utils/scroll_command.dart';

class TabsRoute extends StatefulWidget {
  const TabsRoute({super.key});

  @override
  State<StatefulWidget> createState() => _TabsRouteState();
}

class _TabsRouteState extends State<TabsRoute> with TickerProviderStateMixin {
  late final _controller = TabController(length: 3, vsync: this);

  final _stream = StreamController<ScrollCommand>();
  late final _playerOverlay =
      OverlayEntry(builder: (ctx) => PlayerRoute(stream: _stream.stream));

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Overlay.of(context).insert(_playerOverlay);
    });
  }

  @override
  void dispose() {
    _playerOverlay.remove();
    _playerOverlay.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _openSettings() {
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        clipBehavior: Clip.hardEdge,
        showDragHandle: true,
        builder: (ctx) => const SettingsRoute());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(onPressed: _openSettings, icon: const Icon(Icons.settings))
        ],
      ),
      bottomSheet: MiniPlayer(stream: _stream),
      bottomNavigationBar: SizedBox(
        height: toolBarHeight,
        child: TabBar(tabs: [
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
        ], controller: _controller),
      ),
      body: TabBarView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Navigator(
              onGenerateRoute: (_) =>
                  MaterialPageRoute(builder: (ctx) => const HomeRoute())),
          Navigator(
              onGenerateRoute: (_) =>
                  MaterialPageRoute(builder: (ctx) => const SearchRoute())),
          Navigator(
              onGenerateRoute: (_) =>
                  MaterialPageRoute(builder: (ctx) => const MediaRoute())),
        ],
      ),
    );
  }
}
