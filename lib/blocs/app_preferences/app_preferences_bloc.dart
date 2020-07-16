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
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  AppPreferencesBloc() : super(AppPreferencesState.initial());

  @override
  Stream<AppPreferencesState> mapEventToState(
    AppPreferencesEvent event,
  ) async* {
    if (event is AppStarted) {
      try {
        final SharedPreferences prefs = await _prefs;
        String apiUrl = prefs.getString('apiUrl');
        yield state.copyWith(initialized: true, apiUrl: apiUrl);
      } catch (e) {
        _log.severe('启动失败，无法获取配置');
      }
    }
    if (event is AppApiUrlChanged) {
      try {
        final SharedPreferences prefs = await _prefs;
        prefs.setString('apiUrl', event.apiUrl);
        yield state.copyWith(apiUrl: event.apiUrl);
      } catch (e) {
        _log.severe('设置服务器网址失败');
      }
    }
  }
}
