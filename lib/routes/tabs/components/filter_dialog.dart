import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FilterDialog extends StatefulWidget {
  final bool details;
  final bool vk;
  final bool vkFriends;
  final bool vkGroups;
  final bool youtube;

  const FilterDialog({
    super.key,
    this.details = false,
    this.vk = true,
    this.vkFriends = true,
    this.vkGroups = true,
    this.youtube = true,
  });

  @override
  State<StatefulWidget> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late bool _vk = widget.vk;
  late bool _vkFriends = widget.vkFriends;
  late bool _vkGroups = widget.vkGroups;
  late bool _youtube = widget.youtube;

  Widget _builder(BuildContext context, ScrollController controller) {
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(AppLocalizations.of(context).filters),
        ),
        Expanded(
          child: ListView(
            controller: controller,
            children: [
              SwitchListTile(
                  title: Text(AppLocalizations.of(context).vk),
                  value: _vk,
                  onChanged: (v) => setState(() => _vk = v)),
              if (widget.details)
                SwitchListTile(
                    contentPadding: const EdgeInsets.only(left: 30, right: 16),
                    title: Text(AppLocalizations.of(context).vkFriends),
                    value: _vk && _vkFriends,
                    onChanged:
                        _vk ? (v) => setState(() => _vkFriends = v) : null),
              if (widget.details)
                SwitchListTile(
                    contentPadding: const EdgeInsets.only(left: 30, right: 16),
                    title: Text(AppLocalizations.of(context).vkGroups),
                    value: _vk && _vkGroups,
                    onChanged:
                        _vk ? (v) => setState(() => _vkGroups = v) : null),
              SwitchListTile(
                  title: Text(AppLocalizations.of(context).yt),
                  value: _youtube,
                  onChanged: (v) => setState(() => _youtube = v)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton(
              onPressed: () => Navigator.pop(
                  context, [_vk, _vkFriends, _vkGroups, _youtube]),
              child: Container(
                  alignment: Alignment.center,
                  width: double.maxFinite,
                  child: Text(AppLocalizations.of(context).apply))),
        ),
        SizedBox(height: MediaQuery.paddingOf(context).bottom)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        snap: true,
        maxChildSize: 0.6,
        initialChildSize: widget.details ? 0.5 : 0.4,
        builder: _builder);
  }
}
