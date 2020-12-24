part of 'app_preferences_bloc.dart';

class AppPreferencesState extends Equatable {
  final bool initialized;
  final String apiUrl;
  final String miPushAppId;
  final String miPushAppKey;
  final String miPushRegId;
  final int refreshInterval;
  final String blogUrl;
  final String blogAdminUrl;
  final AppTab defaultPage;
  final User loginUser;

  const AppPreferencesState({
    @required this.initialized,
    @required this.apiUrl,
    @required this.miPushAppId,
    @required this.miPushAppKey,
    @required this.miPushRegId,
    @required this.refreshInterval,
    @required this.blogUrl,
    @required this.blogAdminUrl,
    @required this.defaultPage,
    @required this.loginUser,
  });

  factory AppPreferencesState.initial() {
    return AppPreferencesState(
      initialized: false,
      apiUrl: null,
      miPushAppId: null,
      miPushAppKey: null,
      miPushRegId: null,
      refreshInterval: 10,
      blogUrl: null,
      blogAdminUrl: null,
      defaultPage: AppTab.storage,
      loginUser: null,
    );
  }

  AppPreferencesState copyWith({
    bool initialized,
    String apiUrl,
    String miPushAppId,
    String miPushAppKey,
    String miPushRegId,
    int refreshInterval,
    String blogUrl,
    String blogAdminUrl,
    AppTab defaultPage,
    User loginUser,
  }) {
    return AppPreferencesState(
      initialized: initialized ?? this.initialized,
      apiUrl: apiUrl ?? this.apiUrl,
      miPushAppId: miPushAppId ?? this.miPushAppId,
      miPushAppKey: miPushAppKey ?? this.miPushAppKey,
      miPushRegId: miPushRegId ?? this.miPushRegId,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      blogUrl: blogUrl ?? this.blogUrl,
      blogAdminUrl: blogAdminUrl ?? this.blogAdminUrl,
      defaultPage: defaultPage ?? this.defaultPage,
      loginUser: loginUser ?? this.loginUser,
    );
  }

  @override
  List<Object> get props => [
        initialized,
        apiUrl,
        miPushAppId,
        miPushAppKey,
        miPushRegId,
        refreshInterval,
        blogUrl,
        blogAdminUrl,
        defaultPage,
        loginUser,
      ];
}