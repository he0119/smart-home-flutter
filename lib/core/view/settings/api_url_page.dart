import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/widgets/text_edit_page.dart';

class ApiUrlPage extends ConsumerWidget {
  const ApiUrlPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final graphqlApiClient = ref.read(graphQLApiClientProvider);

    return TextEditPage(
      title: '服务器网址',
      initialValue: settings.apiUrl,
      onSubmit: (value) {
        graphqlApiClient.initailize(value);
        settingsNotifier.updateApiUrl(value);
      },
      description: '要连接的服务器网址',
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
