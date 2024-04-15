import 'package:flutter/material.dart';
import 'package:music/utils/utils.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchAppBar extends StatefulWidget {
  final Proc1<String>? onChanged;
  final VoidCallback? openFilter;

  const SearchAppBar({super.key, this.onChanged, this.openFilter});

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

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
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
        IconButton(onPressed: _clear, icon: const Icon(Icons.clear)),
        IconButton(
            onPressed: widget.openFilter,
            icon: const Icon(Icons.filter_alt_outlined)),
      ],
    );
  }
}
