import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/core/bloc/blocs.dart';
import 'package:smarthome/widgets/text_edit_page.dart';

class ApiUrlPage extends StatelessWidget {
  const ApiUrlPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
      builder: (context, state) => TextEditPage(
        title: '服务器网址',
        initialValue: state.apiUrl ?? '请输入网址',
        onSubmit: (value) {
          BlocProvider.of<AppPreferencesBloc>(context).add(
            AppApiUrlChanged(apiUrl: value),
          );
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
