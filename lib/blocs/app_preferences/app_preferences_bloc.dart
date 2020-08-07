import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/models/app_tab.dart';

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
        int refreshInterval = prefs.getInt('refreshInterval');
        String blogUrl = prefs.getString('blogUrl');
        String blogAdminUrl = prefs.getString('blogAdminUrl');
        AppTab defaultPage = EnumToString.fromString(
            AppTab.values, prefs.getString('defaultPage'));
        yield state.copyWith(
          initialized: true,
          apiUrl: apiUrl,
          refreshInterval: refreshInterval,
          blogUrl: blogUrl,
          blogAdminUrl: blogAdminUrl,
          defaultPage: defaultPage,
        );
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
    if (event is AppIotRefreshIntervalChanged) {
      try {
        final SharedPreferences prefs = await _prefs;
        prefs.setInt('refreshInterval', event.interval);
        yield state.copyWith(refreshInterval: event.interval);
      } catch (e) {
        _log.severe('设置物联网更新间隔失败');
      }
    }
    if (event is AppBlogUrlChanged) {
      try {
        final SharedPreferences prefs = await _prefs;
        prefs.setString('blogUrl', event.blogUrl);
        prefs.setString('blogAdminUrl', event.blogAdminUrl);
        yield state.copyWith(
          blogUrl: event.blogUrl,
          blogAdminUrl: event.blogAdminUrl,
        );
      } catch (e) {
        _log.severe('设置博客网址失败');
      }
    }
    if (event is DefaultPageChanged) {
      try {
        final SharedPreferences prefs = await _prefs;
        prefs.setString('defaultPage', EnumToString.parse(event.defaultPage));
        yield state.copyWith(
          defaultPage: event.defaultPage,
        );
      } catch (e) {
        _log.severe('设置默认主页失败');
      }
    }
  }
}
