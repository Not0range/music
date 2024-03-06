String msLabel(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s < 10 ? '0$s' : '$s'}';
}
