import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/data/models/vk/profile_vk.dart';
import 'package:music/data/models/yt/profile_yt.dart';
import 'package:music/routes/settings/components/account_info.dart';
import 'package:music/routes/settings/components/login_dialog.dart';
import 'package:music/utils/box_icons.dart';
import 'package:music/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'settings_presenter.dart';

class SettingsRoute extends StatelessWidget {
  const SettingsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppModel>(context);
    return SettingsRouteWrapper(
      vkToken: state.vkToken,
      vkProfile: state.vkProfile,
      ytToken: state.ytToken,
      ytProfile: state.ytProfile,
      setVkToken: (t) => state.vkToken = t,
      setYtToken: (t) => state.ytToken = t,
      setVkProfile: (p) => state.vkProfile = p,
      setYtProfile: (p) => state.ytProfile = p,
    );
  }
}

class SettingsRouteWrapper extends StatefulWidget {
  final String? vkToken;
  final String? ytToken;
  final ProfileVk? vkProfile;
  final ProfileYt? ytProfile;
  final Proc1<String?>? setVkToken;
  final Proc1<String?>? setYtToken;
  final Proc1<ProfileVk?>? setVkProfile;
  final Proc1<ProfileYt?>? setYtProfile;

  const SettingsRouteWrapper(
      {super.key,
      this.vkToken,
      this.ytToken,
      this.vkProfile,
      this.ytProfile,
      this.setVkToken,
      this.setYtToken,
      this.setVkProfile,
      this.setYtProfile});

  @override
  State<StatefulWidget> createState() => _SettingsRouteWrapperState();
}

class _SettingsRouteWrapperState extends SettingsRouteContract
    with SettingsPresenter {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      if (widget.vkProfile == null && widget.vkToken != null) getVkProfile();
      if (widget.ytProfile == null && widget.ytToken != null) {}
    });
  }

  Widget _builder(BuildContext context, ScrollController controller) {
    var t = Theme.of(context);
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(AppLocalizations.of(context).settings),
        ),
        Expanded(
          child: ListView(
            controller: controller,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 0, 0),
                child: Text(
                  AppLocalizations.of(context).services,
                  style: t.textTheme.bodyLarge,
                ),
              ),
              AccountInfo(
                icon: BoxIcons.vk,
                name: widget.vkProfile?.name,
                id: widget.vkProfile?.id.toString(),
                avatar: widget.vkProfile?.avatar,
                onTap: widget.vkToken != null ? _logoutVk : _loginVk,
                loading: widget.vkProfile == null && widget.vkToken != null,
              ),
              AccountInfo(
                icon: BoxIcons.youtube,
                name: null,
                id: null,
                onTap: widget.ytToken != null ? _logoutYt : _loginYt,
                loading: widget.ytProfile == null && widget.ytToken != null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 1, expand: false, snap: true, builder: _builder);
  }

  void _loginVk() {
    showDialog(
        context: context,
        builder: (ctx) => LoginDialog(
              title: 'VK',
              onSubmit: loginVk,
            ));
  }

  void _logoutVk() {
    //TODO invalidate token
    widget.setVkToken?.call(null);
    widget.setVkProfile?.call(null);
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('vk_token');
    });
  }

  void _loginYt() {}

  void _logoutYt() {}

  @override
  void onSuccessLoginVk(String token) {
    widget.setVkToken?.call(token);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('vk_token', token);
    });
    getVkProfile();
  }

  @override
  void onSuccessProfileVk(ProfileVk profile) {
    widget.setVkProfile?.call(profile);
  }

  @override
  void onErrorVk(String error) {
    _logoutVk();
  }
}
