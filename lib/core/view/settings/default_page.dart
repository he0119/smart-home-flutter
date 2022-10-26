import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarthome/app/settings/settings_controller.dart';
import 'package:smarthome/core/model/models.dart';
import 'package:smarthome/widgets/home_page.dart';
import 'package:smarthome/widgets/settings/settings.dart';

class DefaultPage extends StatelessWidget {
  const DefaultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settings, child) => MySliverPage(
        title: '默认主页',
        sliver: SettingsList(
          sections: [
            SettingsSection(tiles: [
              SettingsTile(
                title: AppTab.iot.name,
                trailing:
                    trailingWidget(context, AppTab.iot, settings.defaultPage),
                onPressed: (context) {
                  context
                      .read<SettingsController>()
                      .updateDefaultPage(AppTab.iot);
                },
              ),
              SettingsTile(
                title: AppTab.storage.name,
                trailing: trailingWidget(
                    context, AppTab.storage, settings.defaultPage),
                onPressed: (context) {
                  context
                      .read<SettingsController>()
                      .updateDefaultPage(AppTab.storage);
                },
              ),
              SettingsTile(
                title: AppTab.blog.name,
                trailing:
                    trailingWidget(context, AppTab.blog, settings.defaultPage),
                onPressed: (context) {
                  context
                      .read<SettingsController>()
                      .updateDefaultPage(AppTab.blog);
                },
              ),
              SettingsTile(
                title: AppTab.board.name,
                trailing:
                    trailingWidget(context, AppTab.board, settings.defaultPage),
                onPressed: (context) {
                  context
                      .read<SettingsController>()
                      .updateDefaultPage(AppTab.board);
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget trailingWidget(BuildContext context, AppTab appTab, AppTab current) {
    return (appTab == current)
        ? Icon(Icons.check, color: Theme.of(context).colorScheme.secondary)
        : const Icon(null);
  }
}
