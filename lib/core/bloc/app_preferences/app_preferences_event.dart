part of 'app_preferences_bloc.dart';

abstract class AppPreferencesEvent extends Equatable {
  const AppPreferencesEvent();

  @override
  List<Object> get props => [];
}

/// 软件启动
class AppStarted extends AppPreferencesEvent {
  @override
  String toString() => 'AppStarted';
}

/// 更改服务器网址
class AppApiUrlChanged extends AppPreferencesEvent {
  final String apiUrl;

  AppApiUrlChanged({required this.apiUrl});

  @override
  List<Object> get props => [apiUrl];

  @override
  String toString() => 'AppApiUrlChanged(apiUrl: $apiUrl)';
}

/// 更改物联网页面的刷新间隔
class AppIotRefreshIntervalChanged extends AppPreferencesEvent {
  final int interval;

  AppIotRefreshIntervalChanged({required this.interval});

  @override
  List<Object> get props => [interval];

  @override
  String toString() => 'AppIotRefreshIntervalChanged(interval: $interval)';
}

/// 更改博客和博客后台网址
class AppBlogUrlChanged extends AppPreferencesEvent {
  final String blogUrl;
  final String blogAdminUrl;

  AppBlogUrlChanged({
    required this.blogUrl,
    required this.blogAdminUrl,
  });

  @override
  List<Object> get props => [blogUrl, blogAdminUrl];

  @override
  String toString() =>
      'AppBlogUrlChanged(blogUrl: $blogUrl, blogAdminUrl: $blogAdminUrl)';
}

/// 更改默认主页
class DefaultPageChanged extends AppPreferencesEvent {
  final AppTab defaultPage;

  DefaultPageChanged({
    required this.defaultPage,
  });

  @override
  List<Object> get props => [defaultPage];

  @override
  String toString() => 'DefaultPageChanged(defaultPage: $defaultPage)';
}

/// 更改登录用户
class LoginUserChanged extends AppPreferencesEvent {
  final User loginUser;

  LoginUserChanged({
    required this.loginUser,
  });

  @override
  List<Object> get props => [loginUser];

  @override
  String toString() => 'LoginUserChanged(loginUser: $loginUser)';
}

/// 更改小米推送密钥
class MiPushKeyChanged extends AppPreferencesEvent {
  final String miPushAppId;
  final String miPushAppKey;

  MiPushKeyChanged({
    required this.miPushAppId,
    required this.miPushAppKey,
  });

  @override
  List<Object> get props => [miPushAppId, miPushAppKey];

  @override
  String toString() => 'MiPushKeyChanged(miPushAppId: $miPushAppId, '
      'miPushAppKey: $miPushAppKey)';
}

/// 更改小米推送注册标识符
class MiPushRegIdChanged extends AppPreferencesEvent {
  final String miPushRegId;

  MiPushRegIdChanged({
    required this.miPushRegId,
  });

  @override
  List<Object> get props => [miPushRegId];

  @override
  String toString() => 'MiPushRegIdChanged(miPushRegId: $miPushRegId)';
}

/// 更改评论排序方式
class CommentDescendingChanged extends AppPreferencesEvent {
  final bool descending;

  CommentDescendingChanged({
    required this.descending,
  });

  @override
  List<Object> get props => [descending];

  @override
  String toString() => 'CommentDescendingChanged(descending: $descending)';
}

/// 更改主题
class ThemeModeChanged extends AppPreferencesEvent {
  final ThemeMode themeMode;

  ThemeModeChanged({
    required this.themeMode,
  });

  @override
  List<Object> get props => [themeMode];

  @override
  String toString() => 'ThemeModeChanged(themeMode: $themeMode)';
}
