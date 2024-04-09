import 'package:music/utils/utils.dart';

class LyricsVk {
  final String lang;
  final String text;

  LyricsVk(this.lang, this.text);

  factory LyricsVk.fromJson(JsonMap json) {
    final lyrics = json['lyrics'];
    return LyricsVk(lyrics['language'], (lyrics['text'] as List).join('\n'));
  }
}
