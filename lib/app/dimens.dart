/// 全局尺寸常量：间距和圆角都从这里取，避免各页面随手写数字。
/// 间距梯度。页面里一律从这里取值，避免出现 5、7、13 这类随手写的数字。
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// 圆角梯度：小控件 8、输入框和按钮 12、卡片 16、弹窗和底部弹层 28。
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 28;
}
