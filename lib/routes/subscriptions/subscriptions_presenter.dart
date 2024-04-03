import 'package:flutter/material.dart';
import 'package:music/data/models/vk/group_vk.dart';
import 'package:music/data/models/vk/user_vk.dart';
import 'package:music/data/repository.dart';

import 'subscriptions_route.dart';

abstract class SubscriptionsContract extends State<SubscriptionsRoute> {
  void onFriends(Iterable<UserVk> users);
  void onGroups(Iterable<GroupVk> groups);
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
}
