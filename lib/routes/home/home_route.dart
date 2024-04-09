import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:music/app_model.dart';
import 'package:music/components/loading_container.dart';
import 'package:music/components/result_category.dart';
import 'package:music/data/models/vk/music_vk.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/styles.dart';
import 'package:provider/provider.dart';

import 'home_presenter.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<StatefulWidget> createState() => _HomeRouteState();
}

class _HomeRouteState extends HomeContract
    with HomePresenter, AutomaticKeepAliveClientMixin {
  List<MusicVk> _recommendationVk = [];
  List<MusicVk> _popularVk = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _load();
    });
  }

  Future<void> _load() async {
    final state = Provider.of<AppModel>(context, listen: false);
    await [state.vkToken != null ? _getVk() : Future.value(), _getYt()].wait;
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _getVk() async {
    await [recommendationsVk(), popularVk()].wait;
  }

  Future<void> _getYt() async {}

  void _favoriteVk(String id) {
    final ids = id.split('_').map((e) => int.parse(e)).toList();
    addVk(ids[0], ids[1]);
  }

  Widget _loadingBuilder(BuildContext context, int _) {
    return ResultCategory.loading();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Widget child;
    if (_loading) {
      child = ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: _loadingBuilder);
    } else {
      child = RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            ResultCategory(
              title: AppLocalizations.of(context).vkRecommendation,
              items: _recommendationVk,
              type: Service.vk,
              addToFavorite: _favoriteVk,
            ),
            ResultCategory(
              title: AppLocalizations.of(context).vkPopular,
              items: _popularVk,
              type: Service.vk,
              addToFavorite: _favoriteVk,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).home),
        actions: [
          IconButton(
              onPressed: () => openSettings(context),
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Shimmer(
          gradient: Theme.of(context).brightness == Brightness.light
              ? shimmerLigth
              : shimmerDark,
          child: child),
    );
  }

  @override
  void onPopularVk(List<MusicVk> result) {
    setState(() {
      _popularVk = result;
    });
  }

  @override
  void onRecommendationsVk(List<MusicVk> result) {
    setState(() {
      _recommendationVk = result;
    });
  }

  @override
  void onFavoriteSuccess() {
    // TODO: implement onFavoriteSuccess
  }

  @override
  bool get wantKeepAlive => true;
}
