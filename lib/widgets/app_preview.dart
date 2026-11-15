import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';
import 'package:smarthome/app/theme.dart';
import 'package:smarthome/l10n/l10n.dart';
import 'package:smarthome/widgets/preview_frame.dart';

/// 预览统一使用的语言。
///
/// 项目主要面向中文用户，`l10n.yaml` 的模板就是 `app_zh.arb`，
/// [AppLocalizations.supportedLocales] 里有 `zh`，所以预览固定用中文，
/// 免得看到的文案是英文、和真机不一致。
const Locale _appPreviewLocale = Locale('zh');

/// 预览里的本地化委托。
///
/// 必须带上 [GlobalMaterialLocalizations]：`MaterialApp` 只用自己那套委托
/// 建立 `MaterialLocalizations`，漏掉它日期选择器、返回按钮的提示语会报错。
/// 写法和 `lib/app/main.dart` 保持一致。
const List<LocalizationsDelegate<dynamic>> _appPreviewLocalizationsDelegates =
    <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ];

/// 组件预览统一用的注解：固定带上应用的亮/暗主题和中文本地化。
///
/// 以前这两件事是 `PreviewFrame` 自己包一层 `MaterialApp` 干的，52 个预览
/// 每个都靠那层隐式主题，换成注解以后「主题从哪来」写在预览声明上，
/// 预览函数只剩布局。
final class AppPreview extends Preview {
  const AppPreview({
    super.name,
    super.group = previewGroupWidgets,
    super.size,
    super.textScaleFactor,
  }) : super(theme: _appPreviewTheme, localizations: _appPreviewLocalizations);
}

/// 预览器只接受编译期常量，所以注解里的回调用顶层函数名（tear-off）。
PreviewThemeData _appPreviewTheme() => const _AppPreviewTheme();

PreviewLocalizationsData _appPreviewLocalizations() =>
    _appPreviewLocalizationsData;

const PreviewLocalizationsData _appPreviewLocalizationsData =
    PreviewLocalizationsData(
      locale: _appPreviewLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: _appPreviewLocalizationsDelegates,
    );

/// 预览用的主题。
///
/// 为什么返回整个 `MaterialApp` 而不是只给 `ThemeData`：组件树里除了
/// `Theme` 还需要 `Navigator`、`Overlay`、`MaterialLocalizations`，弹窗、
/// SnackBar、输入框都依赖它们，只套 `Theme` 会在预览里直接抛错。
/// 官方示例里的 `PreviewMaterialThemeData` 在本项目使用的 material_ui
/// 1.11.0 和 Flutter 3.50 里不存在，所以自己实现 [PreviewThemeData]。
final class _AppPreviewTheme extends PreviewThemeData {
  const _AppPreviewTheme();

  @override
  Widget apply(BuildContext context, Widget child) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // 亮色、暗色都备好，由预览器给的 platformBrightness 决定用哪套：
      // 卡片上的「Switch to dark mode」和 @Preview(brightness:) 都是改这个值。
      theme: buildLightTheme(null),
      darkTheme: buildDarkTheme(null),
      themeMode: ThemeMode.system,
      locale: _appPreviewLocale,
      localizationsDelegates: _appPreviewLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}
