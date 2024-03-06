import 'dart:math' as math;

typedef JsonMap = Map<String, dynamic>;

typedef Proc1<T> = void Function(T);

String generateRandomStr(int length) {
  return List.generate(length, (_) => _randomChar()).join();
}

String _randomChar() {
  final i = math.Random().nextInt(16);
  if (i < 10) return '$i';
  return String.fromCharCode(('a'.codeUnits.first) + i - 10);
}
