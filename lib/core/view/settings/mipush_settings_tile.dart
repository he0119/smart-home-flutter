import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:smarthome/core/bloc/blocs.dart';
import 'package:smarthome/core/view/settings/mipush_page.dart';

class MiPushSettingsTile extends SettingsTile {
  MiPushSettingsTile() : super(title: '');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PushBloc, PushState>(
      builder: (context, state) {
        var status = '注册中';
        if (state is PushSuccess) {
          status = '已注册';
        }
        if (state is PushError) {
          status = '注册失败';
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
