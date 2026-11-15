import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smarthome/app/dimens.dart';
import 'package:smarthome/app/theme.dart';
import 'package:smarthome/core/model/app_config.dart';
import 'package:smarthome/core/providers/authentication_provider.dart';
import 'package:smarthome/core/model/app_tab.dart';
import 'package:smarthome/core/providers/settings_provider.dart';
import 'package:smarthome/user/model/user.dart';

/// 组件预览的外壳：套上应用的亮色主题，并给出一块手机宽度的画布。
///
/// 只在 IDE 的 Widget Previewer 里用，业务页面不要引用它。
/// 不加这层外壳的话，`Theme.of(context)` 拿到的是 Flutter 默认主题，
/// 预览里看到的按钮高度、文字层级都和真机不一样。
class PreviewFrame extends StatelessWidget {
  const PreviewFrame({
    super.key,
    required this.child,
    this.width = 400,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.withScaffold = true,
  });

  final Widget child;

  /// 画布宽度。传 null 表示跟随预览窗口铺满。
  final double? width;

  final EdgeInsetsGeometry padding;

  /// 被预览的组件自带 Scaffold 时传 false，避免套出两层页面骨架。
  final bool withScaffold;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: child);
    final canvasWidth = width;
    if (canvasWidth != null) {
      // 顶部对齐：组件按自身高度显示，不会被拉伸到整屏
      content = Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: canvasWidth, child: content),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // 亮色、暗色都备好，由预览器给的 platformBrightness 决定用哪套：
      // 卡片上的「Switch to dark mode」和 @Preview(brightness:) 都是改这个值。
      theme: buildLightTheme(null),
      darkTheme: buildDarkTheme(null),
      themeMode: ThemeMode.system,
      home: withScaffold ? Scaffold(body: SafeArea(child: content)) : content,
    );
  }
}

/// 预览里用的基础分组名，保证侧边栏按目录归类。
const String previewGroupWidgets = '通用组件';
const String previewGroupSettings = '设置组件';
const String previewGroupStorage = '物品组件';
const String previewGroupBoard = '留言板组件';
const String previewGroupAuth = '登录组件';

/// 预览用的假应用配置。
///
/// [appConfigProvider] 正常是在 bootstrap 里覆盖成真配置的，
/// 预览环境没有 bootstrap，不覆盖就会直接抛错。
AppConfig previewAppConfig() => AppConfig(
  appName: '智慧家庭',
  flavorName: '预览',
  defaultApiUrl: 'https://smart.example.com',
  defaultAdminUrl: 'https://smart.example.com/admin',
  defaultBlogUrl: 'https://blog.example.com',
);

/// 预览用的假设置。
SettingsState previewSettings({
  User? loginUser,
  String? loginMethod,
  String? miPushRegId,
}) => SettingsState(
  loginUser: loginUser,
  themeMode: ThemeMode.system,
  defaultPage: AppTab.storage,
  apiUrl: 'https://smart.example.com',
  adminUrl: 'https://smart.example.com/admin',
  blogUrl: 'https://blog.example.com',
  miPushRegId: miPushRegId,
  refreshInterval: 30,
  commentDescending: false,
  loginMethod: loginMethod,
  appConfig: previewAppConfig(),
);

/// 需要 Riverpod 的组件套这一层。
///
/// 默认只覆盖 [appConfigProvider]；传了 [settings] 就把设置也换掉；
/// [fakeAuth] 用于登录页——真跑一遍启动检查会去请求后端，预览里不需要。
class PreviewProviders extends StatelessWidget {
  const PreviewProviders({
    super.key,
    required this.child,
    this.settings,
    this.fakeAuth = false,
  });

  final Widget child;
  final SettingsState? settings;
  final bool fakeAuth;

  @override
  Widget build(BuildContext context) {
    final previewSettingsState = settings;
    return ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(previewAppConfig()),
        if (previewSettingsState != null)
          settingsProvider.overrideWith(
            () => _PreviewSettingsNotifier(previewSettingsState),
          ),
        if (fakeAuth)
          authenticationProvider.overrideWith(
            () => _PreviewAuthenticationNotifier(),
          ),
      ],
      child: child,
    );
  }
}

class _PreviewSettingsNotifier extends Settings {
  _PreviewSettingsNotifier(this._state);

  final SettingsState _state;

  @override
  SettingsState build() => _state;
}

class _PreviewAuthenticationNotifier extends Authentication {
  @override
  AuthState build() => AuthState(user: const AsyncValue.data(null));
}
