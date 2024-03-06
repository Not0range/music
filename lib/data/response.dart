import 'package:music/utils/utils.dart';

class ResponseVk<T> {
  final T? response;
  final VkErrorObject? error;

  ResponseVk(this.response, this.error);

  factory ResponseVk.fromJson(JsonMap json, T Function(JsonMap) builder) {
    return ResponseVk(
        json['response'] != null ? builder(json['response']) : null,
        json['error'] != null ? VkErrorObject.fromJson(json['error']) : null);
  }
}

class VkErrorObject {
  final int code;
  final String message;

  VkErrorObject(this.code, this.message);

  factory VkErrorObject.fromJson(JsonMap json) {
    return VkErrorObject(json['code'], json['message']);
  }
}
