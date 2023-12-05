import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smarthome/core/bloc/blocs.dart';
import 'package:smarthome/core/view/settings/mipush_page.dart';
import 'package:smarthome/widgets/settings/settings.dart';

class MiPushSettingsTile extends StatelessWidget {
  const MiPushSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PushBloc, PushState>(
      builder: (context, state) {
        var status = '未知';
        if (state is PushInProgress) {
          status = '注册中';
        }
        if (state is PushSuccess) {
          status = '已注册';
        }
        if (state is PushError) {
          status = state.message;
        }
        return SettingsTile(
          title: '小米推送',
          subtitle: status,
          onPressed: (context) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MiPushPage(),
              ),
            );
          },
        );
      },
    );
  }
}
