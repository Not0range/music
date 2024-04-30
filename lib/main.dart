import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:music/app_model.dart';
import 'package:music/data/clients/vk_client.dart';
import 'package:music/data/clients/yt_client.dart';
import 'package:music/data/repository.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:music/routes/player_wrapper/player_wrapper.dart';
import 'package:music/utils/player_helper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/player.dart';
import 'routes/tabs/tabs_route.dart';
import 'utils/utils.dart';

const _saveTimeout = Duration(seconds: 30);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = StreamController<ChangePlayableType>.broadcast();
  final prefs = await SharedPreferences.getInstance();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
        create: (ctx) => AppModel(
            vkToken: prefs.getString('vk_token'),
            ytToken: prefs.getString('yt_token'))),
    ChangeNotifierProvider(create: (ctx) => PlayerModel(controller)),
    ChangeNotifierProvider(create: (ctx) => PlaylistsModel()),
  ], child: MainApp(stream: controller.stream)));
}

class MainApp extends StatefulWidget {
  final Stream<ChangePlayableType> stream;

  const MainApp({super.key, required this.stream});

  @override
  State<StatefulWidget> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Timer? _listTimer;
  Timer? _sheffleTimer;
  Timer? _queueTimer;

  final _vkClient = VkClient();
  final _ytClient = YtClient();

  late final StreamSubscription _durationSub;
  late final StreamSubscription _positionSub;
  late final StreamSubscription _stateSub;
  late final StreamSubscription _completeSub;

  final _controller = StreamController<BroadcastCommand>.broadcast();
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _listeners);
  }

  @override
  void deactivate() {
    final state = Provider.of<PlayerModel>(context, listen: false);
    if (_listTimer?.isActive ?? false) _saveList(state);
    if (_queueTimer?.isActive ?? false) _saveQueue(state);
    if (_sheffleTimer?.isActive ?? false) _saveShuffled(state);

    super.deactivate();
  }

  @override
  void dispose() {
    _durationSub.cancel();
    _positionSub.cancel();
    _stateSub.cancel();
    _completeSub.cancel();

    _controller.close();
    _subscription.cancel();

    super.dispose();
  }

  void _listeners() {
    final state = Provider.of<PlayerModel>(context, listen: false);
    _initPlayer(state).then((_) {
      _subscription = widget.stream.listen((c) => _streamListener(state, c));
    });

    _durationSub =
        PlayerHelper.instance.durationStream.listen((d) => state.duration = d);
    _positionSub =
        PlayerHelper.instance.positionStream.listen((p) => state.position = p);
    _stateSub =
        PlayerHelper.instance.stateStream.listen((s) => state.playing = s);
    _completeSub = PlayerHelper.instance.completionStream.listen((_) {
      if (state.queue.isNotEmpty) {
        state.fromQueue = true;
        final q = state.enqueue();
        state.setItem(q, favorite: '${q.extra?['favorite'] ?? ''}');

        if (q.url.isNotEmpty) {
          PlayerHelper.instance.play(q.url, q.toJson());
        } else {
          _controller.add(BroadcastCommand(
              BroadcastCommandType.needUrl, q.type, {'fromQueue': true}));
        }
        return;
      }
      state.fromQueue = false;
      if (state.index == null) return;

      var i = state.index! + 1;
      if (i >= state.list.length) i = 0;

      state.index = i;
      final item = (state.shuffled ?? state.list)[i];
      state.setItem(item, favorite: '${item.extra?['favorite'] ?? ''}');

      if (item.url.isNotEmpty) {
        PlayerHelper.instance.play(item.url, item.toJson());
      } else {
        _controller.add(BroadcastCommand(
            BroadcastCommandType.needUrl, item.type, {'fromQueue': false}));
      }

      PlayerHelper.instance
          .setBookmark(item.extra?['favorite']?.toString().isNotEmpty ?? false);

      if (item.coverBig == null) return;
      DefaultCacheManager()
          .getSingleFile(item.coverBig!)
          .then((file) => PlayerHelper.instance.setMetadataCover(file.path));
    });
  }

  void _streamListener(PlayerModel state, ChangePlayableType c) {
    switch (c) {
      case ChangePlayableType.list:
        _listTimer?.cancel();
        _listTimer = Timer(_saveTimeout, () => _saveList(state));
        break;
      case ChangePlayableType.queue:
        _queueTimer?.cancel();
        _queueTimer = Timer(_saveTimeout, () => _saveQueue(state));
        break;
      case ChangePlayableType.shuffled:
        _sheffleTimer?.cancel();
        _sheffleTimer = Timer(_saveTimeout, () => _saveShuffled(state));
        break;
      case ChangePlayableType.trackIndex:
        SharedPreferences.getInstance().then((prefs) async {
          if (state.index != null) {
            await prefs.setInt('trackIndex', state.index!);
          } else {
            await prefs.remove('trackIndex');
          }
        });
        break;
    }
  }

  Future<void> _initPlayer(PlayerModel state) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('player_list')) return;

    final index = prefs.getInt('trackIndex') ?? 0;
    final queue = prefs
            .getStringList('player_queue')
            ?.map((e) => MusicInfo.fromJson(jsonDecode(e)))
            .toList() ??
        [];
    final fromQueue = queue.isNotEmpty;
    final shuffled = prefs
        .getStringList('player_shuffle')
        ?.map((e) => MusicInfo.fromJson(jsonDecode(e)))
        .toList();
    final list = prefs
        .getStringList('player_list')!
        .map((e) => MusicInfo.fromJson(jsonDecode(e)))
        .toList();
    final item = queue.isNotEmpty
        ? queue.removeAt(0)
        : shuffled != null
            ? shuffled[index]
            : list[index];

    state.list = list;
    state.shuffled = shuffled;
    state.queue = queue;
    state.fromQueue = fromQueue;
    state.index = index;
    state.setItem(item);

    await Future.delayed(const Duration(seconds: 1));
    _controller.add(BroadcastCommand(
        BroadcastCommandType.needUrl, item.type, {'fromQueue': fromQueue}));
  }

  Future<void> _saveList(PlayerModel state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'player_list', state.list.map((e) => jsonEncode(e.toJson())).toList());
    await prefs.setInt('trackIndex', state.index ?? 0);
  }

  Future<void> _saveQueue(PlayerModel state) async {
    final prefs = await SharedPreferences.getInstance();
    if (state.queue.isEmpty) {
      prefs.remove('player_queue');
      return;
    }
    var list = state.queue.map((e) => jsonEncode(e.toJson()));
    if (state.fromQueue) {
      list = [
        jsonEncode({
          'id': state.id,
          'artist': state.artist,
          'title': state.title,
          'duration': state.duration,
          'coverSmall': state.img,
          'coverBig': state.img,
          'type': state.service!.index
        })
      ].followedBy(list);
    }

    await prefs.setStringList('player_queue', list.toList());
  }

  Future<void> _saveShuffled(PlayerModel state) async {
    final prefs = await SharedPreferences.getInstance();
    if (state.shuffled != null) {
      await prefs.setStringList('player_shuffle',
          state.shuffled!.map((e) => jsonEncode(e.toJson())).toList());
    } else {
      await prefs.remove('player_shuffle');
    }
    await prefs.setInt('trackIndex', state.index ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Repository(
      _vkClient,
      _ytClient,
      child: PlayerCommand(
        _controller,
        child: PlayerWrapper(
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
      ),
    );
  }
}
