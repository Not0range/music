import 'package:flutter/material.dart';
import 'package:music/components/net_image.dart';
import 'package:music/data/models/vk/group_vk.dart';
import 'package:music/data/models/vk/user_vk.dart';
import 'package:music/components/playlist_item.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/service_objects.dart';

import 'subscriptions_presenter.dart';

class SubscriptionsRoute extends StatefulWidget {
  const SubscriptionsRoute({super.key});

  @override
  State<StatefulWidget> createState() => _SubscriptionsRouteState();
}

class _SubscriptionsRouteState extends SubscriptionsContract
    with SubscriptionsPresenter, AutomaticKeepAliveClientMixin {
  Iterable<UserVk> _friends = [];
  Iterable<GroupVk> _groups = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _load();
    });
  }

  Future<void> _load() async {
    await [getFriends(), getGroups()].wait;
  }

  Widget? _builder(BuildContext context, int index) {
    final String name;
    final String id;
    final String avatar;

    if (index >= _friends.length) {
      final item = _groups.elementAtOrNull(index - _friends.length);
      if (item == null) return null;
      name = item.title;
      id = '-${item.id}';
      avatar = item.avatar;
    } else {
      final item = _friends.elementAtOrNull(index);
      if (item == null) return null;
      name = '${item.firstName} ${item.lastName}';
      id = '${item.id}';
      avatar = item.avatar;
    }

    return PlaylistItem(
      leading: Container(
        height: 46,
        width: 46,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        child: NetImage(
          img: avatar,
          placeholder: const Icon(Icons.person),
        ),
      ),
      type: Service.vk,
      title: name,
      onTap: () => openUser(context, name, User(Service.vk, id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
        onRefresh: _load,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ListView.builder(
              itemCount: _friends.length + _groups.length,
              itemBuilder: _builder),
        ));
  }

  @override
  void onFriends(Iterable<UserVk> users) {
    setState(() {
      _friends = users.where((e) => e.audioAccess);
    });
  }

  @override
  void onGroups(Iterable<GroupVk> groups) {
    setState(() {
      _groups = groups;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
