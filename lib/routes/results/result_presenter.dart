import 'package:flutter/material.dart';
import 'package:music/data/repository.dart';

import 'results_route.dart';

abstract class ResultContract extends State<ResultRoute> {
  void onFavoriteSuccess();
}

mixin ResultPresenter on ResultContract {
  Future<void> addVk(int ownerId, int id) async {
    try {
      final r = Repository.vkOf(context);
      await r.addToFavorite(context, ownerId, id);
      onFavoriteSuccess();
    } catch (e) {}
  }
}
