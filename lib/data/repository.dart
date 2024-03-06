import 'package:flutter/material.dart';

import 'clients/vk_client.dart';
import 'clients/yt_client.dart';

class Repository extends InheritedWidget {
  final VkClient vkClient;
  final YtClient ytClient;

  const Repository(this.vkClient, this.ytClient,
      {super.key, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static VkClient? vkMaybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Repository>()?.vkClient;
  }

  static VkClient vkOf(BuildContext context) {
    final result = vkMaybeOf(context);
    assert(result != null, 'No RepositoryClient found in context');
    return result!;
  }

  static YtClient? ytMaybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Repository>()?.ytClient;
  }

  static YtClient ytOf(BuildContext context) {
    final result = ytMaybeOf(context);
    assert(result != null, 'No RepositoryClient found in context');
    return result!;
  }
}
