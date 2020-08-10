import 'package:flutter/material.dart';

/// 显示消息条
///
/// 显示时间 [duration] 的单位为秒，默认为 4 秒
void showInfoSnackBar(
  BuildContext context,
  String message, {
  int duration = 4,
}) {
  Scaffold.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: duration),
    ),
  );
}

/// 显示红色错误提示消息条
///
/// 显示时间 [duration] 的单位为秒，默认为 4 秒
void showErrorSnackBar(
  BuildContext context,
  String message, {
  int duration = 4,
}) {
  Scaffold.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: duration),
      backgroundColor: Colors.red,
    ),
  );
}
