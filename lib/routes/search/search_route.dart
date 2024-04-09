import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/loading_container.dart';
import 'package:music/data/models/vk/music_vk.dart';
import 'package:music/components/result_category.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/styles.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'components/search_bar.dart';
import 'search_presenter.dart';

final _whiteSpace = RegExp(r'^\s*$');

class SearchRoute extends StatefulWidget {
  const SearchRoute({super.key});

  @override
  State<StatefulWidget> createState() => _SearchRouteState();
}

class _SearchRouteState extends SearchContract
    with SearchPresenter, AutomaticKeepAliveClientMixin {
  Timer? _delay;

  List<MusicVk> _resultVk = [];

  List<MusicVk> _resultYt = [];

  String _query = '';

  bool _loading = false;

  @override
  void dispose() {
    _delay?.cancel();
    super.dispose();
  }

  void _search(String query) {
    _delay?.cancel();
    _query = query;

    if (_whiteSpace.hasMatch(_query)) {
      setState(() {
        _resultVk = [];
        _resultYt = [];
      });
      return;
    }

    if (!_loading) setState(() => _loading = true);
    _delay = Timer(const Duration(seconds: 1), _doSearch);
  }

  Future<void> _doSearch() async {
    final state = Provider.of<AppModel>(context, listen: false);
    await [
      state.vkToken != null ? searchVk(_query) : Future.value(),
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
    } else {
      child = ListView(
        children: [
          if (_resultVk.isEmpty && _resultYt.isEmpty)
            Text(
              AppLocalizations.of(context).searchInvite,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ResultCategory(
            title: AppLocalizations.of(context).vk,
            items: _resultVk,
            type: Service.vk,
            forwardTitle: false,
            addToFavorite: _favoriteVk,
          ),
          ResultCategory(
            title: AppLocalizations.of(context).yt,
            items: _resultYt,
            type: Service.youtube,
            forwardTitle: false,
          ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: SearchAppBar(onChanged: _search)),
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
