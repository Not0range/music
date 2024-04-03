import 'package:flutter/material.dart';
import 'package:music/data/models/vk/profile_vk.dart';
import 'package:music/data/repository.dart';

import 'tabs_route.dart';

abstract class TabsContract extends State<TabsRoute> {
  void onSuccessVk(ProfileVk profile);
  void onErrorVk(String error);
}

mixin TabsPresenter on TabsContract {
  Future<void> getVkProfile() async {
    try {
      final r = Repository.vkOf(context);
      onSuccessVk(await r.getProfile(context));
    } catch (e) {
      onErrorVk(e.toString());
    }
  }
}
