import 'package:flutter/material.dart';
import 'package:music/data/models/vk/playlist_vk.dart';
import 'package:music/data/repository.dart';
import 'package:music/routes/media/media_route.dart';

abstract class MediaContract extends State<MediaRoute> {
  void onSuccessVk(Iterable<PlaylistVk> result);
  void onError(String error);
}

mixin MediaPresenter on MediaContract {
  Future<void> getVkPlaylists(int ownerId) async {
    try {
      final r = Repository.vkOf(context);
      onSuccessVk(await r.getPlaylists(context, ownerId));
    } catch (e) {}
  }
}
