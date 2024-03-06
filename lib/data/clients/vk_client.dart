import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/data/models/vk/profile_vk.dart';
import 'package:music/data/response.dart';
import 'package:music/utils/constants.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';

class VkClient {
  final _dio = Dio(BaseOptions(
    baseUrl: 'https://api.vk.com/method/',
    followRedirects: true,
    queryParameters: {'v': vkApiVersion},
    validateStatus: (status) => status != null && status >= 100 && status < 500,
  ));

  VkClient() {
    _dio.interceptors
        .add(LogInterceptor(requestBody: true, responseBody: true));
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.userAgent =
          'VKAndroidApp/5.52-4553 (Android 5.1.1; SDK 22; x86_64; '
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
              'lang': 'ru',
              'device_id': generateRandomStr(16),
            },
            data: FormData.fromMap({'username': login, 'password': password})))
        .data;
    if (data['error'] != null) {
      throw data['error_description'];
    }
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
}
