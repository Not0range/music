import 'package:flutter/material.dart';
import 'package:music/data/models/vk/music_vk.dart';
import 'package:music/data/repository.dart';

import 'search_route.dart';

abstract class SearchContract extends State<SearchRoute> {
  void onSuccessVk(Iterable<MusicVk> result);
  void onError(String error);
}

mixin SearchPresenter on SearchContract {
  Future<void> searchVk(String query) async {
    try {
      final r = Repository.vkOf(context);
      onSuccessVk(await r.searchMusic(context, query));
    } catch (e) {
      onError(e.toString());
    }
  }
}
