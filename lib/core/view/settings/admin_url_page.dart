import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/core/bloc/blocs.dart';
import 'package:smarthome/widgets/text_edit_page.dart';

class AdminUrlPage extends StatelessWidget {
  const AdminUrlPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
      builder: (context, state) => TextEditPage(
        title: '管理网址',
        initialValue: state.adminUrl,
        onSubmit: (value) {
          BlocProvider.of<AppPreferencesBloc>(context).add(
            AppAdminUrlChanged(adminUrl: value),
          );
        },
        description: '管理的网址',
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
