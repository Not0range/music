import 'package:flutter/material.dart';
import 'package:music/data/models/vk/music_vk.dart';
import 'package:music/data/models/vk/playlist_vk.dart';
import 'package:music/data/repository.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/utils.dart';

import 'user_route.dart';

abstract class UserContract extends State<UserRoute> {
  void onFavoritesSuccess(List<MusicVk> result);
  void onPlaylistsSuccess(List<PlaylistVk> result);
  void onFavoriteSuccess();
  void onItemsSuccess(List<IMusic> result, PlaylistStartMode mode);
  void onFollowSuccess(Service service);
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

  Future<void> addVk(int ownerId, int id) async {
    try {
      final r = Repository.vkOf(context);
      await r.addToFavorite(context, ownerId, id);
      onFavoriteSuccess();
    } catch (e) {}
  }

  Future<void> getFromPlaylistVk(int playlistId, PlaylistStartMode mode,
      {int? ownerId}) async {
    try {
      final r = Repository.vkOf(context);
      onItemsSuccess(
          await r.getUserMusic(context,
              ownerId: ownerId, playlistId: playlistId),
          mode);
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> followPlaylistVk(int ownerId, int playlistId) async {
    try {
      final r = Repository.vkOf(context);
      await r.followPlaylist(context, ownerId, playlistId);
      onFollowSuccess(Service.vk);
    } catch (e) {
      onError(e.toString());
    }
  }
}
