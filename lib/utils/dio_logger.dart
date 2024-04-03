import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioLogger extends Interceptor {
  final void Function(String)? printFunc;

  DioLogger([this.printFunc]);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _print('REQ ${options.method} ${options.path} ${options.queryParameters}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _print('RES ${response.statusCode} ${response.requestOptions.path} '
        '${response.data.toString().replaceAll('\n', ' ')}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _print('ERR ${err.requestOptions.path} $err');
    handler.next(err);
  }

  void _print(String log) {
    if (printFunc != null) {
      printFunc?.call(log);
      return;
    }

    if (kDebugMode) print(log);
  }
}
