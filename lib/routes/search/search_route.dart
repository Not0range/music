import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/loading_container.dart';
import 'package:music/data/models/vk/music_vk.dart';
import 'package:music/components/result_category.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/styles.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/search_bar.dart';
import 'search_presenter.dart';

class SearchRoute extends StatefulWidget {
  const SearchRoute({super.key});

  @override
  State<StatefulWidget> createState() => _SearchRouteState();
}

class _SearchRouteState extends SearchContract
    with SearchPresenter, AutomaticKeepAliveClientMixin {
  Timer? _delay;

  bool _vk = true;
  bool _youtube = true;

  List<MusicVk> _resultVk = [];

  List<MusicVk> _resultYt = [];

  String _query = '';

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initParams();
  }

  Future<void> _initParams() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _vk = prefs.getBool('search_filter_vk') ?? true;
      _youtube = prefs.getBool('search_filter_youtube') ?? true;
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    super.dispose();
  }

  Future<void> _filterDialog() async {
    final result = await openFilterDialog(context, vk: _vk, youtube: _youtube);
    if (result == null) return;

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('search_filter_vk', result[0]);
    prefs.setBool('search_filter_youtube', result[3]);

    if (!mounted) return;
    final needVk = !_vk && result[0];
    final needYoutube = !_youtube && result[3];

    setState(() {
      _vk = result[0];
      _youtube = result[3];
    });

    if (whiteSpaceRegex.hasMatch(_query)) return;
    setState(() => _loading = true);
    _doSearch(vk: needVk, youtube: needYoutube);
  }

  void _search(String query) {
    _delay?.cancel();
    _query = query;

    if (whiteSpaceRegex.hasMatch(_query)) {
      setState(() {
        _resultVk = [];
        _resultYt = [];
      });
      return;
    }

    if (!_loading) setState(() => _loading = true);
    _delay = Timer(const Duration(seconds: 1),
        () => _doSearch(vk: _vk, youtube: _youtube));
  }

  Future<void> _doSearch({bool vk = true, bool youtube = true}) async {
    final state = Provider.of<AppModel>(context, listen: false);
    await [
      vk && state.vkToken != null ? searchVk(_query) : Future.value(),
      Future.value() //TODO yt search
    ].wait;
    if (mounted) setState(() => _loading = false);
  }

  void _favoriteVk(String id) {
    final ids = id.split('_').map((e) => int.parse(e)).toList();
    addVk(ids[0], ids[1]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final Widget child;
    if (_loading) {
      child = ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [ResultCategory.loading(), ResultCategory.loading()],
      );
    } else if (_vk || _youtube) {
      child = ListView(
        children: [
          if (_resultVk.isEmpty && _resultYt.isEmpty)
            Text(
              AppLocalizations.of(context).searchInvite,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          if (_vk)
            ResultCategory(
              title: AppLocalizations.of(context).vk,
              items: _resultVk,
              type: Service.vk,
              forwardTitle: false,
              addToFavorite: _favoriteVk,
            ),
          if (_youtube)
            ResultCategory(
              title: AppLocalizations.of(context).yt,
              items: _resultYt,
              type: Service.youtube,
              forwardTitle: false,
            ),
        ],
      );
    } else {
      child = Center(
        child: Text(
          AppLocalizations.of(context).emptyFiltersSearch,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: SearchAppBar(
            onChanged: _search,
            openFilter: _filterDialog,
          )),
      body: Shimmer(
        gradient: Theme.of(context).brightness == Brightness.light
            ? shimmerLigth
            : shimmerDark,
        child: child,
      ),
    );
  }

  @override
  void onSuccessVk(List<MusicVk> result) {
    if (!mounted) return;

    setState(() {
      _resultVk = result;
    });
  }

  @override
  void onFavoriteSuccess() {
    // TODO: implement onFavoriteSuccess
  }

  @override
  void onError(String error) {
    // TODO: implement onError
  }

  @override
  bool get wantKeepAlive => true;
}
