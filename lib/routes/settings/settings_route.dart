import 'package:flutter/material.dart';
import 'package:music/app_model.dart';
import 'package:music/data/models/vk/profile_vk.dart';
import 'package:music/routes/settings/components/account_info.dart';
import 'package:music/routes/settings/components/login_dialog.dart';
import 'package:music/utils/box_icons.dart';
import 'package:provider/provider.dart';

import 'settings_presenter.dart';

class SettingsRoute extends StatelessWidget {
  const SettingsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
        builder: (ctx, state, _) => SettingsRouteWrapper(state: state));
  }
}

class SettingsRouteWrapper extends StatefulWidget {
  final AppModel state;

  const SettingsRouteWrapper({super.key, required this.state});

  @override
  State<StatefulWidget> createState() => _SettingsRouteWrapperState();
}

class _SettingsRouteWrapperState extends SettingsRouteContract
    with SettingsPresenter {
  AppModel get _state => widget.state;

  bool get _needLoadVk => _state.vkProfile == null && _state.vkToken != null;
  bool get _needLoadYt => _state.ytProfile == null && _state.ytToken != null;

  @override
  void initState() {
    super.initState();

    if (_needLoadVk) getVkProfile();
    if (_needLoadYt) {}
  }

  Widget _builder(BuildContext context, ScrollController controller) {
    final vkProfile = _state.vkProfile;
    final ytProfile = _state.ytProfile;

    return SingleChildScrollView(
      controller: controller,
      child: Column(
        children: [
          AccountInfo(
            icon: BoxIcons.vk,
            name: vkProfile?.name,
            id: '12345',
            onTap: _state.vkToken != null ? _logoutVk : _loginVk,
            loading: _needLoadVk,
          ),
          AccountInfo(
            icon: BoxIcons.youtube,
            name: 'a1',
            id: '54321',
            onTap: _state.ytToken != null ? _logoutYt : _loginYt,
            loading: _needLoadYt,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 1,
        minChildSize: 0.9,
        expand: false,
        snap: true,
        builder: _builder);
  }

  void _loginVk() {
    showDialog(
        context: context,
        builder: (ctx) => LoginDialog(
              title: 'VK',
            ));
  }

  void _logoutVk() {}

  void _loginYt() {}

  void _logoutYt() {}

  @override
  void onSuccessVk(ProfileVk profile) {}

  @override
  void onErrorVk(String error) {
    // TODO: implement onErrorVk
  }
}
