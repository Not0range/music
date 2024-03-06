import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginDialog extends StatefulWidget {
  final String title;
  final void Function(String, String)? onSubmit;

  const LoginDialog({super.key, required this.title, this.onSubmit});

  @override
  State<StatefulWidget> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  String _login = '';

  String _password = '';

  void _setLogin(String value) {
    setState(() => _login = value);
  }

  void _setPassword(String value) {
    setState(() => _password = value);
  }

  void _submit() {
    widget.onSubmit?.call(_login, _password);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title),
            TextField(
                onChanged: _setLogin,
                decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    hintText: AppLocalizations.of(context).login)),
            TextField(
                onChanged: _setPassword,
                obscureText: true,
                decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    hintText: AppLocalizations.of(context).password)),
            OutlinedButton(
                onPressed: _submit,
                child: Text(AppLocalizations.of(context).signIn))
          ],
        ),
      ),
    );
  }
}
