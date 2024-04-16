import 'package:flutter/material.dart';
import 'package:music/data/models/vk/group_vk.dart';
import 'package:music/data/models/vk/user_vk.dart';
import 'package:music/data/repository.dart';
import 'package:music/utils/utils.dart';

import 'subscriptions_route.dart';

abstract class SubscriptionsContract extends State<SubscriptionsRoute> {
  void onFriends(List<UserVk> users);
  void onGroups(List<GroupVk> groups);
  void onItemsSuccess(List<IMusic> result, {bool add = false});
  void onError(String error);
}

mixin SubscriptionsPresenter on SubscriptionsContract {
  Future<void> getFriends() async {
    try {
      final r = Repository.vkOf(context);
      onFriends(await r.getFriends(context));
    } catch (e) {}
  }

  Future<void> getGroups() async {
    try {
      final r = Repository.vkOf(context);
      onGroups(await r.getGroups(context));
    } catch (e) {}
  }

  Future<void> getFavoritesVk(int ownerId) async {
    try {
      final r = Repository.vkOf(context);
      onItemsSuccess(await r.getUserMusic(context, ownerId: ownerId));
    } catch (e) {
      onError(e.toString());
    }
  }
}
