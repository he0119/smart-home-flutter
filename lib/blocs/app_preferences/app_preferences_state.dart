part of 'app_preferences_bloc.dart';

class AppPreferencesState extends Equatable {
  final bool initialized;
  final String apiUrl;
  final int refreshInterval;

  const AppPreferencesState({
    @required this.initialized,
    @required this.apiUrl,
    @required this.refreshInterval,
  });

  factory AppPreferencesState.initial() {
    return AppPreferencesState(
      initialized: false,
      apiUrl: null,
      refreshInterval: 10,
    );
  }

  AppPreferencesState copyWith({
    bool initialized,
    String apiUrl,
    int refreshInterval,
  }) {
    return AppPreferencesState(
      initialized: initialized ?? this.initialized,
      apiUrl: apiUrl ?? this.apiUrl,
      refreshInterval: refreshInterval ?? this.refreshInterval,
    );
  }

  @override
  List<Object> get props => [
        initialized,
        apiUrl,
        refreshInterval,
      ];
}
