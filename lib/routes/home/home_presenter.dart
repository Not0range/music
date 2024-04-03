import 'package:flutter/material.dart';
import 'package:music/data/models/vk/music_vk.dart';
import 'package:music/data/repository.dart';

import 'home_route.dart';

abstract class HomeContract extends State<HomeRoute> {
  void onRecommendationsVk(Iterable<MusicVk> result);
  void onPopularVk(Iterable<MusicVk> result);
}

mixin HomePresenter on HomeContract {
  Future<void> recommendationsVk() async {
    try {
      final r = Repository.vkOf(context);
      onRecommendationsVk(await r.getRecommended(context));
    } catch (e) {}
  }

  Future<void> popularVk() async {
    try {
      final r = Repository.vkOf(context);
      onPopularVk(await r.getPopular(context));
    } catch (e) {}
  }
}
