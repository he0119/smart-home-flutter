import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_preferences_event.dart';
part 'app_preferences_state.dart';

class AppPreferencesBloc
    extends Bloc<AppPreferencesEvent, AppPreferencesState> {
  static final Logger _log = Logger('AppPreferencesBloc');
  SharedPreferences _prefs;

  AppPreferencesBloc() : super(AppPreferencesState.initial());

  SharedPreferences get prefs => _prefs;

  @override
  Stream<AppPreferencesState> mapEventToState(
    AppPreferencesEvent event,
  ) async* {
    if (event is AppStarted) {
      // 初始化 SharedPreferences
      _prefs = await SharedPreferences.getInstance().catchError((e) {
        _log.severe('shared prefrences error : $e');
        throw Exception('shared prefrences error');
      });
      String apiUrl = _prefs.getString('apiUrl');
      yield state.copyWith(initialized: true, apiUrl: apiUrl);
    } else if (event is AppApiUrlChanged) {
      _prefs.setString('apiUrl', event.apiUrl);
      yield state.copyWith(apiUrl: event.apiUrl);
    }
  }
}
