import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smarthome/core/model/app_tab.dart';
import 'package:smarthome/core/router/router_extensions.dart';
import 'package:smarthome/core/providers/navigator_context_provider.dart';

part 'tab_provider.g.dart';

/// Tab notifier - 管理底部导航栏的当前标签
@riverpod
class Tab extends _$Tab {
  @override
  AppTab? build() => null;

  void setTab(AppTab? tab) {
    state = tab;
    // 使用go_router进行导航
    if (tab != null) {
      final context = ref.read(navigatorContextProvider);
      if (context != null) {
        context.goTab(tab);
      }
    }
  }
}
