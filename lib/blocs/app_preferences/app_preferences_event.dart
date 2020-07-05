part of 'app_preferences_bloc.dart';

abstract class AppPreferencesEvent extends Equatable {
  const AppPreferencesEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AppPreferencesEvent {}

class ApiUrlChanged extends AppPreferencesEvent {
  final String apiUrl;

  ApiUrlChanged({@required this.apiUrl});

  @override
  List<Object> get props => [apiUrl];
}
