import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/blocs/core/blocs.dart';
import 'package:smarthome/pages/settings/widgets/text_edit_page.dart';

class RefreshIntervalPage extends StatelessWidget {
  const RefreshIntervalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppPreferencesBloc, AppPreferencesState>(
      builder: (context, state) => TextEditPage(
        title: '刷新间隔',
        initialValue: state.refreshInterval.toString(),
        onSubmit: (value) {
          BlocProvider.of<AppPreferencesBloc>(context).add(
            AppIotRefreshIntervalChanged(interval: int.parse(value)),
          );
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
