import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/model/app_tab.dart';

/// Tab notifier - 管理底部导航栏的当前标签
class TabNotifier extends Notifier<AppTab?> {
  @override
  AppTab? build() => null;

  void setTab(AppTab? tab) {
    state = tab;
  }
}

/// Tab provider
final tabProvider = NotifierProvider<TabNotifier, AppTab?>(TabNotifier.new);
