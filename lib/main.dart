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

  @override
  void initState() {
    super.initState();
    AudioPlayer.global.setAudioContext(const AudioContext(
        android: AudioContextAndroid(stayAwake: true),
        iOS: AudioContextIOS(options: [
          AVAudioSessionOptions.allowAirPlay,
          AVAudioSessionOptions.allowBluetoothA2DP
        ])));

    Future.delayed(Duration.zero, _listeners);
  }

  @override
  void dispose() {
    _durationSub.cancel();
    _positionSub.cancel();
    _stateSub.cancel();

    player.dispose();

    super.dispose();
  }

  void _listeners() {
    final state = Provider.of<PlayerModel>(context, listen: false);
    _durationSub = player.onDurationChanged.listen((d) => state.duration = d);
    _positionSub = player.onPositionChanged.listen((d) => state.position = d);
    _stateSub = player.onPlayerStateChanged
        .listen((s) => state.playing = s == PlayerState.playing);
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
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TabsRoute(),
        ),
      ),
    );
  }
}
