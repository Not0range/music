import 'package:music/utils/utils.dart';

class ListResult<T> {
  final int count;
  final List<T> items;

  ListResult(this.count, this.items);

  factory ListResult.fromJson(JsonMap json, T Function(dynamic) constr) {
    final list = (json['items'] as List).map(constr).toList();
    return ListResult(json['count'], list);
  }
}
