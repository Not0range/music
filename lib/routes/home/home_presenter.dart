import 'package:flutter/material.dart';
import 'package:music/data/models/vk/music_vk.dart';
import 'package:music/data/repository.dart';
import 'package:music/utils/service.dart';

import 'home_route.dart';

abstract class HomeContract extends State<HomeRoute> {
  void onRecommendationsVk(List<MusicVk> result);
  void onPopularVk(List<MusicVk> result);
  void onFavoriteSuccess(Service service);
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

  Future<void> addVk(int ownerId, int id) async {
    try {
      final r = Repository.vkOf(context);
      await r.addToFavorite(context, ownerId, id);
      onFavoriteSuccess(Service.vk);
    } catch (e) {}
  }
}
