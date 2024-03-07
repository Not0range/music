import 'package:flutter/material.dart';
import 'package:music/components/net_image.dart';
import 'package:music/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResultCategory extends StatelessWidget {
  final String title;
  final Iterable<IMusic> items;
  final VoidCallback? onOpenned;

  const ResultCategory(
      {super.key, required this.title, required this.items, this.onOpenned});

  Widget _builder(BuildContext context, int index) {
    final item1 = items.elementAtOrNull(index * 2)?.info;
    final item2 = items.elementAtOrNull(index * 2 + 1)?.info;

    return Column(
      children: [
        item1 != null ? ResultItem(info: item1) : const SizedBox.shrink(),
        item2 != null ? ResultItem(info: item2) : const SizedBox.shrink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 150,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 10, 5),
            child: Row(
              children: [
                Expanded(child: Text(title)),
                if (onOpenned != null)
                  TextButton(
                      onPressed: onOpenned,
                      child: Text(AppLocalizations.of(context).more))
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
                controller: PageController(viewportFraction: 0.8),
                itemCount: (items.length / 2).ceil(),
                itemBuilder: _builder),
          )
        ],
      ),
    );
  }
}

class ResultItem extends StatelessWidget {
  final MusicInfo info;

  const ResultItem({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Row(
        children: [
          const NetImage(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(info.title), Text(info.artist)],
          )
        ],
      ),
    );
  }
}
