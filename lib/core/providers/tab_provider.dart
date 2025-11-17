import 'package:riverpod/legacy.dart';
import 'package:smarthome/core/model/app_tab.dart';

/// Tab provider - 管理底部导航栏的当前标签
/// 使用 StateProvider 因为只是简单的状态值
final tabProvider = StateProvider<AppTab?>((ref) => null);
