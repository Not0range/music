import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/data/models/vk/music_vk.dart';
import 'package:music/routes/search/components/result_category.dart';
import 'package:provider/provider.dart';

import 'components/search_bar.dart';
import 'search_presenter.dart';

class SearchRoute extends StatefulWidget {
  const SearchRoute({super.key});

  @override
  State<StatefulWidget> createState() => _SearchRouteState();
}

class _SearchRouteState extends SearchContract with SearchPresenter {
  Timer? _delay;

  Iterable<MusicVk> _resultVk = [];

  Iterable<MusicVk> _resultYt = [];

  String _query = '';

  @override
  void dispose() {
    _delay?.cancel();
    super.dispose();
  }

  void _search(String query) {
    _delay?.cancel();
    _query = query;

    _delay = Timer(const Duration(milliseconds: 500), _doSearch);
  }

  void _doSearch() {
    final state = Provider.of<AppModel>(context, listen: false);
    if (state.vkToken != null) searchVk(_query);
    if (state.ytToken != null) {} //TODO yt search
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: SearchAppBar(onChanged: _search)),
      body: ListView(
        children: [
          ResultCategory(title: 'VK', items: _resultVk),
          ResultCategory(title: 'YT', items: _resultYt),
        ],
      ),
    );
  }

  @override
  void onSuccessVk(Iterable<MusicVk> result) {
    if (!mounted) return;

    setState(() {
      _resultVk = result;
    });
  }

  @override
  void onError(String error) {
    // TODO: implement onError
  }
}
