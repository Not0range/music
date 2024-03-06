import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class Player extends InheritedWidget {
  final AudioPlayer player;

  const Player(this.player, {super.key, required super.child});

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
}
