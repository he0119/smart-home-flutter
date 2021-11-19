import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:smarthome/core/settings/settings_controller.dart';
import 'package:smarthome/widgets/text_edit_page.dart';

class ApiUrlPage extends StatelessWidget {
  const ApiUrlPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settings, child) => TextEditPage(
        title: '服务器网址',
        initialValue: settings.apiUrl,
        onSubmit: (value) {
          context.read<SettingsController>().updateApiUrl(value);
        },
        description: '要连接的服务器网址',
        validator: (value) {
          if (value.startsWith(RegExp(r'^https?://'))) {
            return null;
          }
          return '网址必须为 http:// 或 https:// 开头，请输入正确的网址';
        },
        keyboardType: TextInputType.url,
      ),
    );
  }
}
