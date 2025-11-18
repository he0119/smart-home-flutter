import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/widgets/text_edit_page.dart';

class BlogAdminUrlPage extends ConsumerWidget {
  const BlogAdminUrlPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return TextEditPage(
      title: '博客管理网址',
      initialValue: settings.blogAdminUrl ?? '',
      onSubmit: (value) {
        ref.read(settingsProvider.notifier).updateBlogAdminUrl(value);
      },
      description: '博客管理页面的网址',
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
