part of 'app_preferences_bloc.dart';

class AppPreferencesState extends Equatable {
  final bool initialized;
  final String apiUrl;
  final int refreshInterval;
  final String blogUrl;
  final String blogAdminUrl;

  const AppPreferencesState({
    @required this.initialized,
    @required this.apiUrl,
    @required this.refreshInterval,
    @required this.blogUrl,
    @required this.blogAdminUrl,
  });

  factory AppPreferencesState.initial() {
    return AppPreferencesState(
      initialized: false,
      apiUrl: null,
      refreshInterval: 10,
      blogUrl: null,
      blogAdminUrl: null,
    );
  }

  AppPreferencesState copyWith({
    bool initialized,
    String apiUrl,
    int refreshInterval,
    String blogUrl,
    String blogAdminUrl,
  }) {
    return AppPreferencesState(
      initialized: initialized ?? this.initialized,
      apiUrl: apiUrl ?? this.apiUrl,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      blogUrl: blogUrl ?? this.blogUrl,
      blogAdminUrl: blogAdminUrl ?? this.blogAdminUrl,
    );
  }

  @override
  List<Object> get props => [
        initialized,
        apiUrl,
        refreshInterval,
        blogUrl,
        blogAdminUrl,
      ];
}
