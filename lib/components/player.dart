import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/utils/utils.dart';

class Player extends InheritedWidget {
  final AudioPlayer player;
  final StreamController<BroadcastCommand> controller;

  const Player(this.player, this.controller, {super.key, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static AudioPlayer? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Player>()?.player;
  }

  static AudioPlayer of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No Player found in context');
    return result!;
  }

  static Stream<BroadcastCommand>? maybeStreamOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<Player>()
        ?.controller
        .stream;
  }

  static Stream<BroadcastCommand> streamOf(BuildContext context) {
    final result = maybeStreamOf(context);
    assert(result != null, 'No Player found in context');
    return result!;
  }

  static void sendCommand(BuildContext context, BroadcastCommand cmd) {
    context.dependOnInheritedWidgetOfExactType<Player>()?.controller.add(cmd);
  }
}
