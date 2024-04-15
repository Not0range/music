import 'package:flutter/material.dart';
import 'package:music/data/models/vk/playlist_vk.dart';
import 'package:music/data/repository.dart';

import 'add_to_playlist_route.dart';

abstract class AddToPlaylistContract extends State<AddToPlaylistRouteWrapper> {
  void onSuccessVk(List<PlaylistVk> result);
  void onSuccessAdded(String playlistId);
}

mixin AddToPlaylistPresenter on AddToPlaylistContract {
  Future<void> getVkPlaylists(int ownerId) async {
    try {
      final r = Repository.vkOf(context);
      onSuccessVk(await r.getPlaylists(context, ownerId));
    } catch (e) {}
  }

  Future<void> addToVkPlaylist(
      int ownerId, int playlistId, String audioId) async {
    try {
      final r = Repository.vkOf(context);
      await r.addToPlaylist(context, ownerId, playlistId, audioId);
      onSuccessAdded('${ownerId}_$playlistId');
    } catch (e) {}
  }
}
