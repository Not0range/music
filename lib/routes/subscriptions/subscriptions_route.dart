import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/data/models/vk/group_vk.dart';
import 'package:music/data/models/vk/user_vk.dart';
import 'package:music/components/playlist_item.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/service_objects.dart';
import 'package:provider/provider.dart';

import 'subscriptions_presenter.dart';

class SubscriptionsRoute extends StatefulWidget {
  const SubscriptionsRoute({super.key});

  @override
  State<StatefulWidget> createState() => _SubscriptionsRouteState();
}

class _SubscriptionsRouteState extends SubscriptionsContract
    with SubscriptionsPresenter, AutomaticKeepAliveClientMixin {
  List<UserVk> _friends = [];
  List<GroupVk> _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _load();
    });
  }

  Future<void> _load() async {
    final state = Provider.of<AppModel>(context, listen: false);
    await [
      state.vkToken != null ? getFriends() : Future.value(),
      state.vkToken != null ? getGroups() : Future.value()
    ].wait;
    if (mounted) setState(() => _loading = false);
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
      leading: avatar,
      service: Service.vk,
      title: name,
      type: PlaylistItemType.user,
      onTap: () => openUser(context, name, User(Service.vk, id)),
    );
  }

  Widget _loadingBuilder(BuildContext context, int _) {
    return const PlaylistItem.loading(type: PlaylistItemType.user);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return ListView.builder(
          padding: const EdgeInsets.only(top: 10),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: _loadingBuilder);
    }

    return RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
            padding: const EdgeInsets.only(top: 10),
            itemCount: _friends.length + _groups.length,
            itemBuilder: _builder));
  }

  @override
  void onFriends(List<UserVk> users) {
    setState(() {
      _friends = users.where((e) => e.audioAccess).toList();
    });
  }

  @override
  void onGroups(List<GroupVk> groups) {
    setState(() {
      _groups = groups;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
