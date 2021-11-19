import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:smarthome/core/settings/settings_controller.dart';
import 'package:smarthome/widgets/text_edit_page.dart';

class RefreshIntervalPage extends StatelessWidget {
  const RefreshIntervalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settings, child) => TextEditPage(
        title: '刷新间隔',
        initialValue: settings.refreshInterval.toString(),
        onSubmit: (value) {
          context
              .read<SettingsController>()
              .updateRefreshInterval(int.parse(value));
        },
        description: '物联网数据的刷新间隔，单位为秒',
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value.isEmpty) {
            return '请输入数字';
          }
          if (int.parse(value) <= 0) {
            return '刷新间隔必须大于 0';
          }
          return null;
        },
      ),
    );
  }
}
