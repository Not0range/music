import 'package:flutter/material.dart';
import 'package:music/data/models/vk/playlist_vk.dart';
import 'package:music/data/repository.dart';
import 'package:music/routes/media/media_route.dart';
import 'package:music/utils/utils.dart';

abstract class MediaContract extends State<MediaRouteWrapper> {
  void onSuccessVk(List<PlaylistVk> result);
  void onItemsSuccess(List<IMusic> result,
      {bool add = false, bool favorite = false});
  void onError(String error);
}

mixin MediaPresenter on MediaContract {
  Future<void> getVkPlaylists(int ownerId) async {
    try {
      final r = Repository.vkOf(context);
      onSuccessVk(await r.getPlaylists(context, ownerId));
    } catch (e) {}
  }

  Future<void> createVkPlaylist(int ownerId, String title, bool private) async {
    try {
      final r = Repository.vkOf(context);
      await r.addPlaylist(context, ownerId, title, private);
      await getVkPlaylists(ownerId);
    } catch (e) {}
  }

  Future<void> removeVkPlaylist(int ownerId, int playlistId) async {
    try {
      final r = Repository.vkOf(context);
      if (await r.removePlaylist(context, ownerId, playlistId)) {
        await getVkPlaylists(ownerId);
      }
    } catch (e) {}
  }

  Future<void> getFavoritesVk({bool add = false}) async {
    try {
      final r = Repository.vkOf(context);
      onItemsSuccess(await r.getUserMusic(context), add: add, favorite: true);
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> getFromPlaylistVk(int albumId,
      {int? ownerId, bool add = false}) async {
    try {
      final r = Repository.vkOf(context);
      onItemsSuccess(
          await r.getUserMusic(context, ownerId: ownerId, albumId: albumId),
          add: add);
    } catch (e) {
      onError(e.toString());
    }
  }
}
