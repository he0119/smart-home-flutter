import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/providers/settings_provider.dart';
import 'package:smarthome/widgets/text_edit_page.dart';

class AdminUrlPage extends ConsumerWidget {
  const AdminUrlPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return TextEditPage(
      title: '管理网址',
      initialValue: settings.adminUrl,
      onSubmit: (value) {
        ref.read(settingsProvider.notifier).updateAdminUrl(value);
      },
      description: '管理的网址',
      validator: (value) {
        if (value.startsWith(RegExp(r'^https?://'))) {
          return null;
        }
        return '网址必须为 http:// 或 https:// 开头，请输入正确的网址';
      },
      keyboardType: TextInputType.url,
    );
  }
}
