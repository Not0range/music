import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/dismiss_container.dart';
import 'package:music/data/models/vk/profile_vk.dart';
import 'package:music/routes/home/home_route.dart';
import 'package:music/routes/media/media_route.dart';
import 'package:music/routes/search/search_route.dart';
import 'package:music/routes/subscriptions/subscriptions_route.dart';
import 'package:music/routes/tabs/components/bottom_bar_player.dart';
import 'package:music/utils/routes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'tabs_presenter.dart';

class TabsRoute extends StatefulWidget {
  const TabsRoute({super.key});

  @override
  State<StatefulWidget> createState() => _TabsRouteState();
}

class _TabsRouteState extends TabsContract
    with TickerProviderStateMixin, TabsPresenter {
  late final _controller = TabController(length: 3, vsync: this);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getVkProfile();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: DismissContainer(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: BottomBarPlayer(controller: _controller),
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
                  onGenerateRoute: (_) => MaterialPageRoute(
                      builder: (ctx) => const LibraryRoute())),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onSuccessVk(ProfileVk profile) {
    Provider.of<AppModel>(context, listen: false).vkProfile = profile;
  }

  @override
  void onErrorVk(String error) {
    // TODO: implement onErrorVk
  }
}

class LibraryRoute extends StatefulWidget {
  const LibraryRoute({super.key});

  @override
  State<StatefulWidget> createState() => _LibraryRouteState();
}

class _LibraryRouteState extends State<LibraryRoute>
    with SingleTickerProviderStateMixin {
  late final _controller = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).mediaLib),
        actions: [
          IconButton(
              onPressed: () => openSettings(context),
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Column(
        children: [
          TabBar.secondary(controller: _controller, tabs: [
            Tab(text: AppLocalizations.of(context).playlists),
            Tab(text: AppLocalizations.of(context).subscriptions)
          ]),
          Expanded(
            child: TabBarView(
                controller: _controller,
                children: const [MediaRoute(), SubscriptionsRoute()]),
          ),
        ],
      ),
    );
  }
}
