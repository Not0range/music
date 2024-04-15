import 'package:flutter/material.dart';
import 'package:music/utils/box_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:music/utils/service.dart';

class SelectServiceDialog extends StatelessWidget {
  const SelectServiceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(AppLocalizations.of(context).createPlaylist),
        ),
        ListTile(
          leading: const Icon(BoxIcons.vk),
          title: Text(AppLocalizations.of(context).vkPlaylist),
          onTap: () => Navigator.pop(context, Service.vk),
        ),
        ListTile(
          leading: const Icon(BoxIcons.youtube),
          title: Text(AppLocalizations.of(context).ytPlaylist),
          onTap: () => Navigator.pop(context, Service.youtube),
        ),
        SizedBox(height: MediaQuery.paddingOf(context).bottom)
      ],
    );
  }
}
