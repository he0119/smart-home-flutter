import 'package:material_ui/material_ui.dart';
import 'package:smarthome/core/core.dart';

/// 显示消息条
///
/// 显示时间 [duration] 的单位为秒，默认为 4 秒
void showInfoSnackBar(String message, {int duration = 4}) {
  scaffoldMessengerKey.currentState!.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: duration),
    ),
  );
}

/// 显示红色错误提示消息条
///
/// 显示时间 [duration] 的单位为秒，默认为 4 秒
void showErrorSnackBar(String message, {int duration = 4}) {
  final context = scaffoldMessengerKey.currentContext;
  final colors = context == null ? null : Theme.of(context).colorScheme;
  scaffoldMessengerKey.currentState!.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: colors == null ? null : TextStyle(color: colors.onError),
      ),
      duration: Duration(seconds: duration),
      backgroundColor: colors?.error,
    ),
  );
}
