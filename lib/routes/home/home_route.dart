import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:music/app_model.dart';
import 'package:music/components/result_category.dart';
import 'package:music/data/models/vk/music_vk.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/service.dart';
import 'package:provider/provider.dart';

import 'home_presenter.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<StatefulWidget> createState() => _HomeRouteState();
}

class _HomeRouteState extends HomeContract
    with HomePresenter, AutomaticKeepAliveClientMixin {
  Iterable<MusicVk> _recommendationVk = [];
  Iterable<MusicVk> _popularVk = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final vk = Provider.of<AppModel>(context, listen: false).vkToken;
      if (vk != null) {
        recommendationsVk();
        popularVk();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).home),
        actions: [
          IconButton(
              onPressed: () => openSettings(context),
              icon: const Icon(Icons.settings))
        ],
      ),
      body: ListView(
        children: [
          ResultCategory(
            title: AppLocalizations.of(context).vkRecommendation,
            items: _recommendationVk,
            type: Service.vk,
          ),
          ResultCategory(
            title: AppLocalizations.of(context).vkPopular,
            items: _popularVk,
            type: Service.vk,
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void onPopularVk(Iterable<MusicVk> result) {
    setState(() {
      _popularVk = result;
    });
  }

  @override
  void onRecommendationsVk(Iterable<MusicVk> result) {
    setState(() {
      _recommendationVk = result;
    });
  }
}
