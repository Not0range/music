import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/data/clients/vk_client.dart';
import 'package:music/data/clients/yt_client.dart';
import 'package:music/data/repository.dart';
import 'package:music/routes/tabs/tabs_route.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
        create: (ctx) => AppModel(
            vkToken: prefs.getString('vk_token'),
            ytToken: prefs.getString('yt_token'))),
    ChangeNotifierProvider(create: (ctx) => PlayerModel()),
  ], child: const MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<StatefulWidget> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _vkClient = VkClient();
  final _ytClient = YtClient();

  final player = AudioPlayer();
  late final StreamSubscription _durationSub;
  late final StreamSubscription _positionSub;
  late final StreamSubscription _stateSub;
  late final StreamSubscription _completeSub;

  @override
  void initState() {
    super.initState();
    AudioPlayer.global.setAudioContext(AudioContext(
        android: const AudioContextAndroid(stayAwake: true),
        iOS: AudioContextIOS()));

    player.positionUpdater = TimerPositionUpdater(
        getPosition: player.getCurrentPosition,
        interval: const Duration(milliseconds: 500));
    player.setReleaseMode(ReleaseMode.stop);
    Future.delayed(Duration.zero, _listeners);
  }

  @override
  void dispose() {
    _durationSub.cancel();
    _positionSub.cancel();
    _stateSub.cancel();
    _completeSub.cancel();

    player.dispose();

    super.dispose();
  }

  void _listeners() {
    final state = Provider.of<PlayerModel>(context, listen: false);
    _durationSub = player.onDurationChanged.listen((d) => state.duration = d);
    _positionSub = player.onPositionChanged.listen((p) => state.position = p);
    _stateSub = player.onPlayerStateChanged.listen((s) => state.playing = s ==
            PlayerState.playing ||
        s == PlayerState.completed && player.releaseMode == ReleaseMode.loop);
    _completeSub = player.onPlayerComplete.listen((_) {
      if (player.releaseMode == ReleaseMode.loop) return;

      if (state.queue.isNotEmpty) {
        state.fromQueue = true;
        final q = state.enqueue();
        state.setItem(q, favorite: '${q.extra?['favorite'] ?? ''}');

        player.play(UrlSource(q.url));
        return;
      }
      state.fromQueue = false;
      if (state.index == null) return;

      var i = state.index! + 1;
      if (i >= state.list.length) i = 0;

      state.index = i;
      final item = (state.shuffled ?? state.list)[i];
      state.setItem(item, favorite: '${item.extra?['favorite'] ?? ''}');
      player.play(UrlSource(item.url));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Repository(
      _vkClient,
      _ytClient,
      child: Player(
        player,
        child: MaterialApp(
          title: 'Music',
          theme: ThemeData(
            appBarTheme: const AppBarTheme(centerTitle: false),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
              appBarTheme: const AppBarTheme(centerTitle: false),
              colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple, brightness: Brightness.dark),
              useMaterial3: true,
              brightness: Brightness.dark),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TabsRoute(),
        ),
      ),
    );
  }
}
