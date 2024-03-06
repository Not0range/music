import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/data/models/vk/profile_vk.dart';
import 'package:music/utils/constants.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';

class VkClient {
  final _dio = Dio(BaseOptions(
    baseUrl: 'https://api.vk.com/method',
    followRedirects: true,
    queryParameters: {'v': vkApiVersion},
  ));

  VkClient() {
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

  Future<void> login(BuildContext context) async {
    final data =
        (await _dio.post('https://oauth.vk.com/token', queryParameters: {
      'grant_type': 'password',
      'client_id': '2274003',
      'client_secret': 'hHbZxrka2uZ6jB1inYsH',
      'scope': 'all',
      'lang': 'en',
      'device_id': generateRandomStr(16),
    }))
            .data;
    print(data);
  }

  Future<ProfileVk> getProfile(BuildContext context) async {
    final data = (await _dio.get('account.getProfileInfo',
            queryParameters: {'access_token': _token(context)}))
        .data;
    return ProfileVk.fromJson(data); //TODO
  }
}
