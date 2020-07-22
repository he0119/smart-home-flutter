part of 'app_preferences_bloc.dart';

abstract class AppPreferencesEvent extends Equatable {
  const AppPreferencesEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AppPreferencesEvent {}

/// 更改服务器网址
class AppApiUrlChanged extends AppPreferencesEvent {
  final String apiUrl;

  AppApiUrlChanged({@required this.apiUrl});

  @override
  List<Object> get props => [apiUrl];

  @override
  String toString() => 'AppApiUrlChanged { apiUrl: $apiUrl }';
}

/// 更改物联网页面的刷新间隔
class AppIotRefreshIntervalChanged extends AppPreferencesEvent {
  final int interval;

  AppIotRefreshIntervalChanged({@required this.interval});

  @override
  List<Object> get props => [interval];

  @override
  String toString() =>
      'AppIotRefreshIntervalChanged { refreshInterval: $interval }';
}

/// 更改博客和博客后台网址
class AppBlogUrlChanged extends AppPreferencesEvent {
  final String blogUrl;
  final String blogAdminUrl;

  AppBlogUrlChanged({
    @required this.blogUrl,
    @required this.blogAdminUrl,
  });

  @override
  List<Object> get props => [blogUrl, blogAdminUrl];

  @override
  String toString() =>
      'AppBlogUrlChanged { blogUrl: $blogUrl, blogAdminUrl: $blogAdminUrl }';
}
