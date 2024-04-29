import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/components/player.dart';
import 'package:music/utils/player_helper.dart';
import 'package:music/utils/service.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';

import 'player_wrapper_presenter.dart';

class PlayerWrapper extends StatefulWidget {
  final Widget child;
  const PlayerWrapper({super.key, required this.child});

  @override
  State<StatefulWidget> createState() => PlayerWrapperState();

  static PlayerWrapperState of(BuildContext context) {
    return context.findAncestorStateOfType<PlayerWrapperState>()!;
  }
}

class PlayerWrapperState extends PlayerWrapperContract
    with PlayerWrapperPresenter {
  late final StreamSubscription _subscription;
  late final StreamSubscription _cmdSubscription;

  @override
  void initState() {
    super.initState();
    _cmdSubscription = PlayerHelper.instance.commandStream.listen((cmd) {
      switch (cmd) {
        case 'prev':
          prev();
          break;
        case 'next':
          next();
        case 'bookmark':
          // toggleFavorite(service, favorite, id);
          break;
        case 'shuffle':
          toggleShuffle();
          break;
        case 'repeat':
          toggleRepeat();
          break;
        default:
      }
    });

    Future.delayed(Duration.zero, () {
      _subscription = PlayerCommand.streamOf(context).listen((cmd) {
        switch (cmd.type) {
          case BroadcastCommandType.needUrl:
            final id = Provider.of<PlayerModel>(context, listen: false).id!;
            switch (cmd.service) {
              case Service.vk:
                getByIdVk(cmd.params?['fromQueue'] == true, id);
                break;
              default:
            }
            break;
          default:
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _cmdSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void playPause(bool playing) {
    final player = PlayerHelper.instance;
    if (!playing) {
      player.resume();
    } else {
      player.pause();
    }
  }

  void prev() {
    final state = Provider.of<PlayerModel>(context, listen: false);
    if (state.index == null) return;

    var i = state.index! - 1;
    if (i < 0) i = state.list.length - 1;

    state.index = i;
    final item = (state.shuffled ?? state.list)[i];
    state.setItem(item, favorite: '${item.extra?['favorite'] ?? ''}');

    if (item.url.isNotEmpty) {
      PlayerHelper.instance.play(item.url, item.toJson());
    } else {
      PlayerCommand.sendCommand(
          context,
          BroadcastCommand(
              BroadcastCommandType.needUrl, item.type, {'fromQueue': false}));
    }
  }

  void next() {
    final state = Provider.of<PlayerModel>(context, listen: false);

    if (state.index != null) {
      var i = state.index! + 1;
      if (i >= state.list.length) i = 0;

      state.index = i;
    }

    final MusicInfo item;
    final bool fromQueue;
    if (state.queue.isNotEmpty) {
      item = state.enqueue();
      fromQueue = true;
    } else {
      if (state.index == null) return;
      item = (state.shuffled ?? state.list)[state.index!];
      fromQueue = false;
    }
    state.fromQueue = fromQueue;
    state.setItem(item, favorite: '${item.extra?['favorite'] ?? ''}');

    if (item.url.isNotEmpty) {
      PlayerHelper.instance.play(item.url, item.toJson());
    } else {
      PlayerCommand.sendCommand(
          context,
          BroadcastCommand(BroadcastCommandType.needUrl, item.type,
              {'fromQueue': fromQueue}));
    }
  }

  void toggleShuffle() {
    final state = Provider.of<PlayerModel>(context, listen: false);
    if (state.list.isEmpty) return;
    state.shuffle = state.shuffled == null;
  }

  void toggleRepeat() {
    final state = Provider.of<PlayerModel>(context, listen: false);
    state.repeat = !state.repeat;
    final player = PlayerHelper.instance;
    if (state.repeat) {
      player.setRepeat(true);
    } else {
      player.setRepeat(false);
    }
  }

  void toggleFavorite(Service? service, FavoriteType favorite, String id) {
    if (service == Service.vk) {
      final ids = id.split('_').map((e) => int.parse(e)).toList();
      if (favorite == FavoriteType.include) {
        final id = Provider.of<AppModel>(context, listen: false).vkProfile?.id;
        if (id != null) removeVk(id, ids[1]);
      } else if (favorite == FavoriteType.exclude) {
        addVk(ids[0], ids[1]);
      } else {
        restoreVk(ids[0], ids[1]);
      }
    }
  }

  @override
  void onError(String error) {
    // TODO: implement onError
  }

  @override
  void onFavoriteSuccess([int? newId]) {
    final state = Provider.of<PlayerModel>(context, listen: false);
    final String favorite;

    if (newId != null) {
      final owner = Provider.of<AppModel>(context, listen: false).vkProfile!.id;
      favorite = '${owner}_$newId';
    } else {
      if (state.favorite == state.id) {
        favorite = 'restore';
      } else {
        favorite = '';
      }
    }
    state.favorite = favorite;
    if (!state.fromQueue) {
      state.replace((state.shuffled ?? state.list)[state.index!]
          .copyWith(extra: {'favorite': favorite}));
    }
  }

  @override
  void onLyricsSuccess(String lyrics) {
    // TODO: implement onLyricsSuccess
  }

  @override
  void onUrlSuccess(bool fromQueue, MusicInfo item) {
    final state = Provider.of<PlayerModel>(context, listen: false);

    state.setItem(item);
    if (!fromQueue) state.replace(item);

    final player = PlayerHelper.instance;
    if (player.source != null) {
      player.play(item.url, item.toJson());
    } else {
      player.setSource(item.url, item.toJson());
    }
  }
}

enum FavoriteType { include, exclude, restore }
