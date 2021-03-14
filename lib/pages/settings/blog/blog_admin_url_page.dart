import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/blocs/core/blocs.dart';
import 'package:smarthome/pages/settings/widgets/text_edit_page.dart';

class BlogAdminUrlPage extends StatelessWidget {
  const BlogAdminUrlPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
      builder: (context, state) => TextEditPage(
        title: '博客管理网址',
        initialValue: state.blogAdminUrl,
        onSubmit: (value) {
          BlocProvider.of<AppPreferencesBloc>(context).add(
            AppBlogUrlChanged(blogUrl: state.blogUrl, blogAdminUrl: value),
          );
        },
        description: '博客管理页面的网址',
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
