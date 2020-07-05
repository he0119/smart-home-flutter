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

  AppPreferencesBloc() : super(AppUninitialized());

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
      AppPreferencesChanged current = await _loadAppPreference();
      yield current;
    } else if (event is ApiUrlChanged) {
      _prefs.setString('apiUrl', event.apiUrl);
      yield AppPreferencesChanged(apiUrl: event.apiUrl);
    }
  }

  Future<AppPreferencesState> _loadAppPreference() async {
    String apiUrl = _prefs.getString('apiUrl');
    return AppPreferencesChanged(apiUrl: apiUrl);
  }
}
