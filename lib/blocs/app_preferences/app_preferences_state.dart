part of 'app_preferences_bloc.dart';

class AppPreferencesState extends Equatable {
  final bool initialized;
  final String apiUrl;

  const AppPreferencesState({
    @required this.initialized,
    @required this.apiUrl,
  });

  factory AppPreferencesState.initial() {
    return AppPreferencesState(
      initialized: false,
      apiUrl: null,
    );
  }

  AppPreferencesState copyWith({
    bool initialized,
    String apiUrl,
  }) {
    return AppPreferencesState(
      initialized: initialized ?? this.initialized,
      apiUrl: apiUrl ?? this.apiUrl,
    );
  }

  @override
  List<Object> get props => [
        initialized,
        apiUrl,
      ];
}
