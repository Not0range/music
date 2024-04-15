import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/data/models/vk/group_vk.dart';
import 'package:music/data/models/vk/list_result.dart';
import 'package:music/data/models/vk/lyrics_vk.dart';
import 'package:music/data/models/vk/music_vk.dart';
import 'package:music/data/models/vk/playlist_vk.dart';
import 'package:music/data/models/vk/profile_vk.dart';
import 'package:music/data/models/vk/user_vk.dart';
import 'package:music/data/response.dart';
import 'package:music/utils/constants.dart';
import 'package:music/utils/dio_logger.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';

class VkClient {
  final _dio = Dio(BaseOptions(
    baseUrl: 'https://api.vk.com/method/',
    followRedirects: true,
    queryParameters: {'v': vkApiVersion, 'lang': 'ru'},
    validateStatus: (status) => status != null && status >= 100 && status < 500,
  ));

  VkClient() {
    _dio.interceptors.add(DioLogger());
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.userAgent =
          'VKAndroidApp/5.52-4543 (Android 5.1.1; SDK 22; x86_64; '
          'unknown Android SDK built for x86_64; en; 320x240)';
      client.badCertificateCallback = (_, __, ___) => true;
      return client;
    };
  }

  String _token(BuildContext context) =>
      Provider.of<AppModel>(context, listen: false).vkToken ?? '';

  Future<String> login(
      BuildContext context, String login, String password) async {
    final data = (await _dio.post('https://oauth.vk.com/token',
            queryParameters: {
              'grant_type': 'password',
              'client_id': '2274003',
              'client_secret': 'hHbZxrka2uZ6jB1inYsH',
              'scope': 'all',
              'device_id': generateRandomStr(16),
            },
            data: FormData.fromMap({'username': login, 'password': password})))
        .data;
    if (data['error'] != null) throw data['error_description'];

    return data['access_token'];
  }

  Future<ProfileVk> getProfile(BuildContext context) async {
    final data = (await _dio.get('account.getProfileInfo',
            queryParameters: {'access_token': _token(context)}))
        .data;
    final res = ResponseVk.fromJson(data, (json) => ProfileVk.fromJson(json));
    if (res.error != null) throw res.error!.message;
    return res.response!;
  }

  Future<List<MusicVk>> searchMusic(BuildContext context, String query,
      [int page = 1]) async {
    final data = (await _dio.get('audio.search', queryParameters: {
      'access_token': _token(context),
      'lyrics': 1,
      'sort': 2,
      'auto_complete': 1,
      'offset': itemPerPage * (page - 1),
      'count': itemPerPage,
      'q': query
    }))
        .data;
    final res = ResponseVk.fromJson(
        data,
        (json) =>
            ListResult<MusicVk>.fromJson(json, (e) => MusicVk.fromJson(e)));
    if (res.error != null) throw res.error!.message;
    return res.response!.items;
  }

  Future<List<MusicVk>> getUserMusic(BuildContext context,
      {int? ownerId, int? albumId}) async {
    final JsonMap params = {'access_token': _token(context)};
    if (ownerId != null) params['owner_id'] = ownerId;
    if (albumId != null) params['album_id'] = albumId;

    final data = (await _dio.get('audio.get', queryParameters: params)).data;
    final res = ResponseVk.fromJson(
        data,
        (json) =>
            ListResult<MusicVk>.fromJson(json, (e) => MusicVk.fromJson(e)));
    if (res.error != null) throw res.error!.message;
    return res.response!.items;
  }

  Future<void> getMusicByIds(BuildContext context, String ids) async {
    final data = (await _dio.get('audio.getById',
            queryParameters: {'access_token': _token(context), 'audios': ids}))
        .data;
    print(data);
  }

  Future<int> addToFavorite(BuildContext context, int ownerId, int id) async {
    final data = (await _dio.get('audio.add', queryParameters: {
      'access_token': _token(context),
      'owner_id': ownerId,
      'audio_id': id
    }))
        .data;
    final res = ResponseVk.fromJson(data, (r) => r as int);
    if (res.error != null) throw res.error!.message;
    return res.response!;
  }

  Future<void> removeFromFavorite(
      BuildContext context, int ownerId, int id) async {
    final data = (await _dio.get('audio.delete', queryParameters: {
      'access_token': _token(context),
      'owner_id': ownerId,
      'audio_id': id
    }))
        .data;
    final res = ResponseVk.fromJson(data, (r) => r as int);
    if (res.error != null) throw res.error!.message;
  }

  Future<MusicVk> restoreFavorite(
      BuildContext context, int ownerId, int id) async {
    final data = (await _dio.get('audio.restore', queryParameters: {
      'access_token': _token(context),
      'owner_id': ownerId,
      'audio_id': id
    }))
        .data;
    final res = ResponseVk.fromJson(data, (json) => MusicVk.fromJson(json));
    if (res.error != null) throw res.error!.message;
    return res.response!;
  }

  Future<void> reorder(BuildContext context, String id,
      {String? nextId, String? prevId}) async {
    final params = {'access_token': _token(context), 'audio_id': id};
    if (nextId != null) params['before'] = nextId;
    if (prevId != null) params['after'] = prevId;

    final data =
        (await _dio.get('audio.reorder', queryParameters: params)).data;
    print('');
  }

  Future<List<PlaylistVk>> getPlaylists(
      BuildContext context, int ownerId) async {
    final data = (await _dio.get('audio.getPlaylists', queryParameters: {
      'access_token': _token(context),
      'owner_id': ownerId
    }))
        .data;
    final res = ResponseVk.fromJson(data,
        (json) => ListResult.fromJson(json, (e) => PlaylistVk.fromJson(e)));
    if (res.error != null) throw res.error!.message;
    return res.response!.items;
  }

  Future<PlaylistVk> addPlaylist(
      BuildContext context, int ownerId, String title, bool private) async {
    final data = (await _dio.get('audio.createPlaylist', queryParameters: {
      'access_token': _token(context),
      'owner_id': ownerId,
      'title': title,
      'no_discover': private ? 1 : 0
    }))
        .data;
    final res = ResponseVk.fromJson(data, (e) => PlaylistVk.fromJson(e));
    if (res.error != null) throw res.error!.message;
    return res.response!;
  }

  Future<bool> editPlaylist(BuildContext context, int ownerId, int playlistId,
      {String? title, bool? private, List<String>? audios}) async {
    final params = {
      'access_token': _token(context),
      'owner_id': ownerId,
      'playlist_id': playlistId
    };
    if (title != null) params['title'] = title;
    if (private != null) params['no_discover'] = private ? 1 : 0;
    if (audios != null) params['audio_ids'] = audios.join(','); //TODO

    if (params.length == 3) throw ArgumentError();

    final data =
        (await _dio.get('audio.editPlaylist', queryParameters: params)).data;
    final res = ResponseVk.fromJson(data, (e) => e as int);
    if (res.error != null) throw res.error!.message;
    return res.response! == 1;
  }

  Future<int> addToPlaylist(
      BuildContext context, int ownerId, int playlistId, String audioId) async {
    final data = (await _dio.get('audio.addToPlaylist', queryParameters: {
      'access_token': _token(context),
      'owner_id': ownerId,
      'playlist_id': playlistId,
      'audio_ids': audioId,
    }))
        .data;
    final res = ResponseVk.fromJson(
        data, (e) => (e as List).map((e) => e['audio_id'] as int));
    if (res.error != null) throw res.error!.message;
    return res.response!.first;
  }

  Future<bool> removePlaylist(
      BuildContext context, int ownerId, int playlistId) async {
    final data = (await _dio.get('audio.deletePlaylist', queryParameters: {
      'access_token': _token(context),
      'owner_id': ownerId,
      'playlist_id': playlistId
    }))
        .data;
    final res = ResponseVk.fromJson(data, (e) => e as int);
    if (res.error != null) throw res.error!.message;
    return res.response == 1;
  }

  Future<List<MusicVk>> getRecommended(BuildContext context,
      [String? target]) async {
    final params = {'access_token': _token(context)};
    if (target != null) params['target_audio'] = target;

    final data =
        (await _dio.get('audio.getRecommendations', queryParameters: params))
            .data;
    final res = ResponseVk.fromJson(
        data, (json) => ListResult.fromJson(json, (e) => MusicVk.fromJson(e)));
    if (res.error != null) throw res.error!.message;
    return res.response!.items;
  }

  Future<List<MusicVk>> getPopular(BuildContext context) async {
    final data = (await _dio.get('audio.getPopular',
            queryParameters: {'access_token': _token(context)}))
        .data;
    final res = ResponseVk.fromJson(data,
        (json) => (json as List).map((e) => MusicVk.fromJson(e)).toList());
    if (res.error != null) throw res.error!.message;
    return res.response!;
  }

  Future<List<UserVk>> getFriends(BuildContext context) async {
    final data = (await _dio.get('friends.get', queryParameters: {
      'access_token': _token(context),
      'order': 'hints',
      'fields': 'photo_100,can_see_audio'
    }))
        .data;
    final res = ResponseVk.fromJson(
        data, (json) => ListResult.fromJson(json, (e) => UserVk.fromJson(e)));
    if (res.error != null) throw res.error!.message;
    return res.response!.items;
  }

  Future<List<GroupVk>> getGroups(BuildContext context) async {
    final data = (await _dio.get('groups.get', queryParameters: {
      'access_token': _token(context),
      'extended': 1,
      'fields': 'photo_100,can_see_audio'
    }))
        .data;
    final res = ResponseVk.fromJson(
        data, (json) => ListResult.fromJson(json, (e) => GroupVk.fromJson(e)));
    if (res.error != null) throw res.error!.message;
    return res.response!.items;
  }

  Future<String> getLyrics(BuildContext context, String id) async {
    final data = (await _dio.get('audio.getLyrics',
            queryParameters: {'access_token': _token(context), 'audio_id': id}))
        .data;
    final res = ResponseVk.fromJson(data, (json) => LyricsVk.fromJson(json));
    if (res.error != null) throw res.error!.message;
    return res.response!.text;
  }
}
