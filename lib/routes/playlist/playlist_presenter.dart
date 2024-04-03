import 'package:flutter/material.dart';
import 'package:music/data/repository.dart';
import 'package:music/routes/playlist/playlist_route.dart';
import 'package:music/utils/utils.dart';

abstract class PlaylistContract extends State<PlaylistRoute> {
  void onSuccess(Iterable<IMusic> result);
  void onError(String error);
}

mixin PlaylistPresenter on PlaylistContract {
  Future<void> getFavoritesVk() async {
    try {
      final r = Repository.vkOf(context);
      onSuccess(await r.getUserMusic(context));
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> getFromPlaylistVk(int albumId, [int? ownerId]) async {
    try {
      final r = Repository.vkOf(context);
      onSuccess(
          await r.getUserMusic(context, ownerId: ownerId, albumId: albumId));
    } catch (e) {
      onError(e.toString());
    }
  }
}