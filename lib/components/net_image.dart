import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetImage extends StatelessWidget {
  final String? img;
  final Widget placeholder;

  const NetImage({super.key, this.img, required this.placeholder});

  @override
  Widget build(BuildContext context) {
    if (img == null || img!.isEmpty) return placeholder;

    return CachedNetworkImage(
      imageUrl: img!,
      fit: BoxFit.contain,
      placeholder: (ctx, s) => placeholder,
      errorWidget: (ctx, s, e) => placeholder,
    );
  }
}
