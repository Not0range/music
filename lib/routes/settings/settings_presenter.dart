import 'package:flutter/material.dart';
import 'package:music/data/models/vk/profile_vk.dart';
import 'package:music/data/repository.dart';
import 'package:music/routes/settings/settings_route.dart';

abstract class SettingsRouteContract extends State<SettingsRouteWrapper> {
  void onSuccessVk(ProfileVk profile);
  void onErrorVk(String error);
}

mixin SettingsPresenter on SettingsRouteContract {
  Future<void> loginVk(String login, String password) async {
    try {
      final r = Repository.vkOf(context);
    } catch (e) {
      onErrorVk(e.toString());
    }
  }

  Future<void> getVkProfile() async {
    try {
      final r = Repository.vkOf(context);
      onSuccessVk(await r.getProfile(context));
    } catch (e) {
      onErrorVk(e.toString());
    }
  }
}
