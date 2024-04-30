import 'package:flutter/material.dart';
import 'package:music/data/repository.dart';

import 'player_wrapper.dart';

abstract class PlayerWrapperContract extends State<PlayerWrapper> {
  void onFavoriteVkSuccess([int? newId]);
  void onLyricsSuccess(String lyrics);
  void onUrlSuccess(bool fromQueue, String url);
  void onError(String error);
}

mixin PlayerWrapperPresenter on PlayerWrapperContract {
  Future<void> addVk(int ownerId, int id) async {
    try {
      final r = Repository.vkOf(context);
      final newId = await r.addToFavorite(context, ownerId, id);
      onFavoriteVkSuccess(newId);
    } catch (e) {}
  }

  Future<void> removeVk(int ownerId, int id) async {
    try {
      final r = Repository.vkOf(context);
      await r.removeFromFavorite(context, ownerId, id);
      onFavoriteVkSuccess();
    } catch (e) {}
  }

  Future<void> restoreVk(int ownerId, int id) async {
    try {
      final r = Repository.vkOf(context);
      final item = await r.restoreFavorite(context, ownerId, id);
      onFavoriteVkSuccess(item.id);
    } catch (e) {}
  }

  Future<void> getLyricsVk(String id) async {
    try {
      final r = Repository.vkOf(context);
      onLyricsSuccess(await r.getLyrics(context, id));
    } catch (e) {}
  }

  Future<void> getByIdVk(bool fromQueue, String id) async {
    try {
      final r = Repository.vkOf(context);
      onUrlSuccess(fromQueue, (await r.getMusicByIds(context, id)).url);
    } catch (e) {}
  }
}
