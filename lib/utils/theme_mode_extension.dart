import 'package:flutter/material.dart';

extension ThemeModeExtension on ThemeMode {
  /// 转换成人类能够看懂的文字
  String toReadable() {
    switch (this) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '浅色';
      case ThemeMode.dark:
        return '深色';
    }
  }
}
