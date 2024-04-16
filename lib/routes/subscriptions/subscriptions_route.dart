import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/player.dart';
import 'package:music/data/models/vk/group_vk.dart';
import 'package:music/data/models/vk/user_vk.dart';
import 'package:music/components/playlist_item.dart';
import 'package:music/utils/routes.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/service_objects.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'subscriptions_presenter.dart';

class SubscriptionsRoute extends StatefulWidget {
  final bool vk;
  final bool vkFriends;
  final bool vkGroups;
  final bool youtube;

  const SubscriptionsRoute(
      {super.key,
      this.vk = true,
      this.vkFriends = true,
      this.vkGroups = true,
      this.youtube = true});

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
      _load(
        vkFriends: widget.vk && widget.vkFriends,
        vkGroups: widget.vk && widget.vkGroups,
        youtube: widget.youtube,
      );
    });
  }

  @override
  void didUpdateWidget(covariant SubscriptionsRoute oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool needVkFriends = false;
    bool needVkGroups = false;
    bool needYoutube = false;
    if (widget.vkFriends != oldWidget.vkFriends) {
      needVkFriends = widget.vk && widget.vkFriends && _friends.isEmpty;
    }
    if (widget.vkGroups != oldWidget.vkGroups) {
      needVkGroups = widget.vk && widget.vkGroups && _groups.isEmpty;
    }
    if (widget.youtube != oldWidget.youtube) {
      // needYoutube =widget.youtube && widget.playlists.ytPlaylists.isEmpty;
    }

    _loading = needVkFriends || needVkGroups || needYoutube;
    _load(
        vkFriends: needVkFriends, vkGroups: needVkGroups, youtube: needYoutube);
  }

  Future<void> _load(
      {bool vkFriends = true,
      bool vkGroups = true,
      bool youtube = true}) async {
    final state = Provider.of<AppModel>(context, listen: false);
    await [
      vkFriends && state.vkToken != null ? getFriends() : Future.value(),
      vkGroups && state.vkToken != null ? getGroups() : Future.value(),
      //TODO load youtube subscriptions
    ].wait;
    if (mounted) setState(() => _loading = false);
  }

  Widget _friendsBuilder(BuildContext context, int i) {
    final item = _friends[i];
    final name = '${item.firstName} ${item.lastName}';

    return PlaylistItem(
      leading: item.avatar,
      service: Service.vk,
      title: name,
      type: PlaylistItemType.user,
      onTap: () => openUser(context, name, User(Service.vk, '${item.id}')),
    );
  }

  Widget _groupsBuilder(BuildContext context, int i) {
    final item = _groups[i];

    return PlaylistItem(
      leading: item.avatar,
      service: Service.vk,
      title: item.title,
      type: PlaylistItemType.user,
      onTap: () =>
          openUser(context, item.title, User(Service.vk, '-${item.id}')),
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

    if (widget.vk && (widget.vkFriends || widget.vkGroups) || widget.youtube) {
      return RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            const SliverPadding(padding: EdgeInsets.only(top: 10)),
            if (widget.vk && widget.vkFriends)
              SliverList.builder(
                  itemCount: _friends.length, itemBuilder: _friendsBuilder),
            if (widget.vk && widget.vkGroups)
              SliverList.builder(
                  itemCount: _groups.length, itemBuilder: _groupsBuilder),
          ],
        ),
      );
    }
    return Center(
      child: Text(
        AppLocalizations.of(context).emptyFilterSubscriptions,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
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
  void onItemsSuccess(List<IMusic> result, {bool add = false}) {
    if (!mounted) return;

    final List<MusicInfo> items = result.map((e) => e.info).toList();

    final state = Provider.of<PlayerModel>(context, listen: false);
    if (add) {
      final empty = state.list.isEmpty;
      state.insertAll(items);
      if (empty) {
        final item = items[0];
        state.setItem(item);
        state.index = 0;
        Player.of(context).setSource(UrlSource(item.url));
      }
    } else {
      state.list = items;

      final item = items[0];
      state.setItem(item);
      state.index = 0;
      Player.of(context).play(UrlSource(item.url));
    }
  }

  @override
  void onError(String error) {
    // TODO: implement onError
  }

  @override
  bool get wantKeepAlive => true;
}
