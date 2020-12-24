import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_home/blocs/core/blocs.dart';
import 'package:smart_home/pages/settings/widgets/text_edit_page.dart';

class BlogUrlPage extends StatelessWidget {
  const BlogUrlPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
      builder: (context, state) => TextEditPage(
        title: '博客网址',
        initialValue: state.blogUrl,
        onSubmit: (value) {
          BlocProvider.of<AppPreferencesBloc>(context).add(
            AppBlogUrlChanged(blogUrl: value, blogAdminUrl: state.blogAdminUrl),
          );
        },
        description: '博客主页的网址',
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
