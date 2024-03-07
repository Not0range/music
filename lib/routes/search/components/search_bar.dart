import 'package:flutter/material.dart';
import 'package:music/utils/utils.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchAppBar extends StatefulWidget {
  final Proc1<String>? onChanged;

  const SearchAppBar({super.key, this.onChanged});

  @override
  State<StatefulWidget> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          textInputAction: TextInputAction.search,
          decoration:
              InputDecoration(hintText: AppLocalizations.of(context).search),
        )),
        IconButton(
            onPressed: () => _controller.clear(), icon: const Icon(Icons.clear))
      ],
    );
  }
}
