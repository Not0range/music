import 'package:flutter/material.dart';
import 'package:music/data/models/new_playlist_model.dart';
import 'package:music/utils/service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:music/utils/utils.dart';

class CreatePlaylistDialog extends StatefulWidget {
  final Service type;
  final String title;
  final PrivacyType privacy;

  const CreatePlaylistDialog(
      {super.key,
      required this.type,
      this.title = '',
      this.privacy = PrivacyType.public});

  @override
  State<StatefulWidget> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  late final _controller = TextEditingController(text: widget.title);
  late var _privacy = widget.privacy;

  void _setPrivacy(PrivacyType? value) {
    if (value == null) return;
    setState(() {
      _privacy = value;
    });
  }

  Widget _privacySetting(BuildContext context) {
    switch (widget.type) {
      case Service.vk:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SwitchListTile(
              title: Text(AppLocalizations.of(context).privatePrivacy),
              value: _privacy == PrivacyType.private,
              onChanged: (c) => _setPrivacy(
                  _privacy = c ? PrivacyType.private : PrivacyType.public)),
        );
      case Service.youtube:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(AppLocalizations.of(context).privacySetting),
                  )),
              ListTile(
                title: Text(
                  AppLocalizations.of(context).publicPrivacy,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                leading: Radio(
                  value: PrivacyType.public,
                  groupValue: _privacy,
                  onChanged: _setPrivacy,
                ),
                contentPadding: EdgeInsets.zero,
                onTap: () => _setPrivacy(PrivacyType.public),
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).linkPrivacy),
                leading: Radio(
                  value: PrivacyType.link,
                  groupValue: _privacy,
                  onChanged: _setPrivacy,
                ),
                contentPadding: EdgeInsets.zero,
                onTap: () => _setPrivacy(PrivacyType.link),
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).privatePrivacy),
                leading: Radio(
                  value: PrivacyType.private,
                  groupValue: _privacy,
                  onChanged: _setPrivacy,
                ),
                contentPadding: EdgeInsets.zero,
                onTap: () => _setPrivacy(PrivacyType.private),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _submit() {
    if (whiteSpaceRegex.hasMatch(_controller.text)) return;

    Navigator.pop(
        context, NewPlaylistModel(widget.type, _controller.text, _privacy));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).newPlaylist,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).title),
              ),
            ),
            _privacySetting(context),
            OutlinedButton(
                onPressed: _submit,
                child: Text(AppLocalizations.of(context).createPlaylist))
          ],
        ),
      ),
    );
  }
}
