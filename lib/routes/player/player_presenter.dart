import 'package:flutter/material.dart';
import 'package:music/data/repository.dart';
import 'package:music/utils/utils.dart';

import 'player_route.dart';

abstract class PlayerContract extends State<PlayerRoute> {
  void onFavoriteSuccess([int? newId]);
  void onLyricsSuccess(String lyrics);
  void onUrlSuccess(bool fromQueue, MusicInfo item);
  void onError(String error);
}

mixin PlayerPresenter on PlayerContract {
  Future<void> addVk(int ownerId, int id) async {
    try {
      final r = Repository.vkOf(context);
      final newId = await r.addToFavorite(context, ownerId, id);
      onFavoriteSuccess(newId);
    } catch (e) {}
  }

  Future<void> removeVk(int ownerId, int id) async {
    try {
      final r = Repository.vkOf(context);
      await r.removeFromFavorite(context, ownerId, id);
      onFavoriteSuccess();
    } catch (e) {}
  }

  Future<void> restoreVk(int ownerId, int id) async {
    try {
      final r = Repository.vkOf(context);
      final item = await r.restoreFavorite(context, ownerId, id);
      onFavoriteSuccess(item.id);
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
      onUrlSuccess(fromQueue, (await r.getMusicByIds(context, id)).info);
    } catch (e) {}
  }
}
