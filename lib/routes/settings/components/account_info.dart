import 'package:flutter/material.dart';
import 'package:music/components/net_image.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountInfo extends StatelessWidget {
  final IconData? icon;
  final String? name;
  final String? id;
  final String? avatar;
  final VoidCallback? onTap;
  final bool loading;

  const AccountInfo(
      {super.key,
      this.icon,
      this.name,
      this.avatar,
      this.id,
      this.onTap,
      this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Icon(icon ?? Icons.person),
          ),
          if (avatar != null)
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: AspectRatio(
                aspectRatio: 1,
                child: NetImage(
                    img: avatar,
                    placeholder: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: Colors.grey, shape: BoxShape.circle),
                      child: const Icon(Icons.person),
                    )),
              ),
            ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(name ?? ''), Text(id ?? '')],
          )),
          Visibility(
            visible: !loading,
            replacement: const CircularProgressIndicator(),
            child: OutlinedButton(
                onPressed: onTap,
                child: Text(name != null && id != null
                    ? AppLocalizations.of(context).signOut
                    : AppLocalizations.of(context).signIn)),
          )
        ],
      ),
    );
  }
}
