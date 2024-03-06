import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:provider/provider.dart';

class YtClient {
  final _dio = Dio(BaseOptions(
    baseUrl: 'https://youtube.com', //TODO
    followRedirects: true,
    queryParameters: {},
  ));

  YtClient() {
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.userAgent = '';
      client.badCertificateCallback = (_, __, ___) => true;
      return client;
    };
  }

  String _token(BuildContext context) =>
      Provider.of<AppModel>(context, listen: false).ytToken ?? '';
}
