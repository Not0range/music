import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music/utils/utils.dart';

class PlayerCommand extends InheritedWidget {
  final StreamController<BroadcastCommand> controller;

  const PlayerCommand(this.controller, {super.key, required super.child});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  static Stream<BroadcastCommand>? maybeStreamOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PlayerCommand>()
        ?.controller
        .stream;
  }

  static Stream<BroadcastCommand> streamOf(BuildContext context) {
    final result = maybeStreamOf(context);
    assert(result != null, 'No Player found in context');
    return result!;
  }

  static void sendCommand(BuildContext context, BroadcastCommand cmd) {
    context
        .dependOnInheritedWidgetOfExactType<PlayerCommand>()
        ?.controller
        .add(cmd);
  }
}
