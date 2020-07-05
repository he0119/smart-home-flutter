part of 'app_preferences_bloc.dart';

abstract class AppPreferencesState extends Equatable {
  const AppPreferencesState();

  @override
  List<Object> get props => [];
}

class AppUninitialized extends AppPreferencesState {}

class AppStartError extends AppPreferencesState {
  final String error;

  const AppStartError(
    this.error,
  );

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'AppStartError { error: $error }';
}

class AppPreferencesChanged extends AppPreferencesState {
  final String apiUrl;

  const AppPreferencesChanged({@required this.apiUrl});

  @override
  List<Object> get props => [apiUrl];
}
