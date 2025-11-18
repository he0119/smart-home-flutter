import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smarthome/core/model/app_tab.dart';

part 'tab_provider.g.dart';

/// Tab notifier - 管理底部导航栏的当前标签
@riverpod
class Tab extends _$Tab {
  @override
  AppTab? build() => null;

  void setTab(AppTab? tab) {
    state = tab;
  }
}
