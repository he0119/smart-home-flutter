part of 'app_preferences_bloc.dart';

abstract class AppPreferencesEvent extends Equatable {
  const AppPreferencesEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AppPreferencesEvent {}

class AppApiUrlChanged extends AppPreferencesEvent {
  final String apiUrl;

  AppApiUrlChanged({@required this.apiUrl});

  @override
  List<Object> get props => [apiUrl];

  @override
  String toString() => 'AppApiUrlChanged { apiUrl: $apiUrl }';
}

class AppIotRefreshIntervalChanged extends AppPreferencesEvent {
  final int interval;

  AppIotRefreshIntervalChanged({@required this.interval});

  @override
  List<Object> get props => [interval];

  @override
  String toString() =>
      'AppIotRefreshIntervalChanged { refreshInterval: $interval }';
}
