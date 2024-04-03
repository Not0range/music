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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: 60,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Icon(
              icon ?? Icons.person,
              size: 30,
            ),
          ),
          if (avatar != null)
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipOval(
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
            ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                id ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
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
