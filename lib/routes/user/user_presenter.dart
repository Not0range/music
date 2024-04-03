import 'package:flutter/material.dart';
import 'package:music/data/models/vk/music_vk.dart';
import 'package:music/data/models/vk/playlist_vk.dart';
import 'package:music/data/repository.dart';

import 'user_route.dart';

abstract class UserContract extends State<UserRoute> {
  void onFavoritesSuccess(Iterable<MusicVk> result);
  void onPlaylistsSuccess(Iterable<PlaylistVk> result);
  void onError(String error);
}

mixin UserPresenter on UserContract {
  Future<void> getVkPlaylists(int ownerId) async {
    try {
      final r = Repository.vkOf(context);
      onPlaylistsSuccess(await r.getPlaylists(context, ownerId));
    } catch (e) {}
  }

  Future<void> getFavoritesVk(int ownerId) async {
    try {
      final r = Repository.vkOf(context);
      onFavoritesSuccess(await r.getUserMusic(context, ownerId: ownerId));
    } catch (e) {
      onError(e.toString());
    }
  }
}
