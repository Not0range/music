import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/data/models/vk/group_vk.dart';
import 'package:music/data/models/vk/list_result.dart';
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
    queryParameters: {'v': vkApiVersion, 'lang': 'en'},
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
              'scope': 'audio,offline',
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

  Future<Iterable<MusicVk>> searchMusic(BuildContext context, String query,
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

  Future<Iterable<MusicVk>> getUserMusic(BuildContext context,
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

  Future<Iterable<PlaylistVk>> getPlaylists(
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

  Future<Iterable<MusicVk>> getRecommended(BuildContext context) async {
    final data = (await _dio.get('audio.getRecommendations',
            queryParameters: {'access_token': _token(context)}))
        .data;
    final res = ResponseVk.fromJson(
        data, (json) => ListResult.fromJson(json, (e) => MusicVk.fromJson(e)));
    if (res.error != null) throw res.error!.message;
    return res.response!.items;
  }

  Future<Iterable<MusicVk>> getPopular(BuildContext context) async {
    final data = (await _dio.get('audio.getPopular',
            queryParameters: {'access_token': _token(context)}))
        .data;
    final res = ResponseVk.fromJson(
        data, (json) => (json as List).map((e) => MusicVk.fromJson(e)));
    if (res.error != null) throw res.error!.message;
    return res.response!;
  }

  Future<Iterable<UserVk>> getFriends(BuildContext context) async {
    final data = (await _dio.get('friends.get', queryParameters: {
      'access_token': _token(context),
      'order': 'name',
      'fields': 'photo_100,can_see_audio'
    }))
        .data;
    final res = ResponseVk.fromJson(
        data, (json) => ListResult.fromJson(json, (e) => UserVk.fromJson(e)));
    if (res.error != null) throw res.error!.message;
    return res.response!.items;
  }

  Future<Iterable<GroupVk>> getGroups(BuildContext context) async {
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
}
