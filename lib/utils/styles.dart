import 'package:flutter/material.dart';

String msLabel(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s < 10 ? '0$s' : '$s'}';
}

const shimmerLigth = LinearGradient(
  colors: [
    Color(0xFFEBEBF4),
    Color(0xFFF4F4F4),
    Color(0xFFEBEBF4),
  ],
  stops: [
    0.1,
    0.3,
    0.4,
  ],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);

const shimmerDark = LinearGradient(
  colors: [
    Color.fromARGB(255, 15, 15, 15),
    Color.fromARGB(255, 59, 59, 59),
    Color.fromARGB(255, 15, 15, 15),
  ],
  stops: [
    0.1,
    0.3,
    0.4,
  ],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);

final shimmerDecor =
    BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(5));

const playerIconSize = 40.0;
