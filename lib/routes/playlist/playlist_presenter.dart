import 'package:flutter/material.dart';
import 'package:music/data/repository.dart';
import 'package:music/routes/playlist/playlist_route.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/utils.dart';

abstract class PlaylistContract extends State<PlaylistRoute> {
  void onSuccess(List<IMusic> result);
  void onFavoriteSuccess(Service service, bool added);
  void onEditSuccess();
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
          await r.getUserMusic(context, ownerId: ownerId, playlistId: albumId));
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> getRelatedVk(String target) async {
    try {
      final r = Repository.vkOf(context);
      onSuccess(await r.getRecommended(context, target));
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> addVk(int ownerId, int id) async {
    try {
      final r = Repository.vkOf(context);
      await r.addToFavorite(context, ownerId, id);
      onFavoriteSuccess(Service.vk, true);
    } catch (e) {}
  }

  Future<void> removeVk(int ownerId, int id) async {
    try {
      final r = Repository.vkOf(context);
      await r.removeFromFavorite(context, ownerId, id);
      onFavoriteSuccess(Service.vk, false);
    } catch (e) {}
  }

  Future<void> reorderVk(String id, {String? nextId, String? prevId}) async {
    try {
      final r = Repository.vkOf(context);
      await r.reorder(context, id, nextId: nextId, prevId: prevId);
    } catch (e) {}
  }

  Future<void> editPlaylistVk(
      int ownerId, int playlistId, List<String> audios) async {
    try {
      final r = Repository.vkOf(context);
      await r.editPlaylist(context, ownerId, playlistId, audios: audios);
      onEditSuccess();
    } catch (e) {
      onError(e.toString());
    }
  }
}
