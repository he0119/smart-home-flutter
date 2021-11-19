import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthome/core/model/models.dart';
import 'package:smarthome/user/user.dart';

part 'app_preferences_event.dart';
part 'app_preferences_state.dart';

class AppPreferencesBloc
    extends Bloc<AppPreferencesEvent, AppPreferencesState> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  AppPreferencesBloc() : super(AppPreferencesState.initial()) {
    on<AppStarted>(_onAppStarted);
    on<AppApiUrlChanged>(_onAppApiUrlChanged);
    on<AppIotRefreshIntervalChanged>(_onAppIotRefreshIntervalChanged);
    on<AppAdminUrlChanged>(_onAppAdminUrlChanged);
    on<AppBlogUrlChanged>(_onAppBlogUrlChanged);
    on<DefaultPageChanged>(_onDefaultPageChanged);
    on<LoginUserChanged>(_onLoginUserChanged);
    on<MiPushKeyChanged>(_onMiPushKeyChanged);
    on<MiPushRegIdChanged>(_onMiPushRegIdChanged);
    on<CommentDescendingChanged>(_onCommentDescendingChanged);
    on<ThemeModeChanged>(_onThemeModeChanged);
  }

  FutureOr<void> _onAppStarted(
      AppStarted event, Emitter<AppPreferencesState> emit) async {
    final prefs = await _prefs;
    final apiUrl = prefs.getString('apiUrl');
    final miPushAppId = prefs.getString('miPushAppId');
    final miPushAppKey = prefs.getString('miPushAppKey');
    final miPushRegId = prefs.getString('miPushRegId');
    final refreshInterval = prefs.getInt('refreshInterval');
    final adminUrl = prefs.getString('adminUrl');
    final blogUrl = prefs.getString('blogUrl');
    final blogAdminUrl = prefs.getString('blogAdminUrl');
    final defaultPageString = prefs.getString('defaultPage');
    final themeModeString = prefs.getString('themeMode');
    AppTab? defaultPage;
    if (defaultPageString != null) {
      defaultPage = EnumToString.fromString(AppTab.values, defaultPageString);
    }
    ThemeMode? themeMode;
    if (themeModeString != null) {
      themeMode = EnumToString.fromString(ThemeMode.values, themeModeString);
    }
    final loginUserJsonString = prefs.getString('loginUser');
    final loginUser = loginUserJsonString != null
        ? User.fromJson(jsonDecode(loginUserJsonString))
        : null;
    final commentDescending =
        prefs.getString('commentDescending')?.toLowerCase() == 'true';
    emit(state.copyWith(
      initialized: true,
      apiUrl: apiUrl,
      miPushAppId: miPushAppId,
      miPushAppKey: miPushAppKey,
      miPushRegId: miPushRegId,
      refreshInterval: refreshInterval,
      adminUrl: adminUrl,
      blogUrl: blogUrl,
      blogAdminUrl: blogAdminUrl,
      defaultPage: defaultPage,
      loginUser: loginUser,
      commentDescending: commentDescending,
      themeMode: themeMode,
    ));
  }

  FutureOr<void> _onAppApiUrlChanged(
      AppApiUrlChanged event, Emitter<AppPreferencesState> emit) async {
    final prefs = await _prefs;
    await prefs.setString('apiUrl', event.apiUrl);
    emit(state.copyWith(apiUrl: event.apiUrl));
  }

  FutureOr<void> _onAppIotRefreshIntervalChanged(
      AppIotRefreshIntervalChanged event,
      Emitter<AppPreferencesState> emit) async {
    final prefs = await _prefs;
    await prefs.setInt('refreshInterval', event.interval);
    emit(state.copyWith(refreshInterval: event.interval));
  }

  FutureOr<void> _onAppAdminUrlChanged(
      AppAdminUrlChanged event, Emitter<AppPreferencesState> emit) async {
    final prefs = await _prefs;
    await prefs.setString('adminUrl', event.adminUrl);
    emit(state.copyWith(
      adminUrl: event.adminUrl,
    ));
  }

  FutureOr<void> _onAppBlogUrlChanged(
      AppBlogUrlChanged event, Emitter<AppPreferencesState> emit) async {
    final prefs = await _prefs;
    await prefs.setString('blogUrl', event.blogUrl);
    await prefs.setString('blogAdminUrl', event.blogAdminUrl);
    emit(state.copyWith(
      blogUrl: event.blogUrl,
      blogAdminUrl: event.blogAdminUrl,
    ));
  }

  FutureOr<void> _onDefaultPageChanged(
      DefaultPageChanged event, Emitter<AppPreferencesState> emit) async {
    final prefs = await _prefs;
    await prefs.setString(
      'defaultPage',
      EnumToString.convertToString(event.defaultPage),
    );
    emit(state.copyWith(
      defaultPage: event.defaultPage,
    ));
  }

  FutureOr<void> _onLoginUserChanged(
      LoginUserChanged event, Emitter<AppPreferencesState> emit) async {
    final prefs = await _prefs;
    await prefs.setString('loginUser', jsonEncode(event.loginUser.toJson()));
    emit(state.copyWith(
      loginUser: event.loginUser,
    ));
  }

  FutureOr<void> _onMiPushKeyChanged(
      MiPushKeyChanged event, Emitter<AppPreferencesState> emit) async {
    final prefs = await _prefs;
    await prefs.setString('miPushAppId', event.miPushAppId);
    await prefs.setString('miPushAppKey', event.miPushAppKey);
    emit(state.copyWith(
      miPushAppId: event.miPushAppId,
      miPushAppKey: event.miPushAppKey,
    ));
  }

  FutureOr<void> _onMiPushRegIdChanged(
      MiPushRegIdChanged event, Emitter<AppPreferencesState> emit) async {
    final prefs = await _prefs;
    await prefs.setString('miPushRegId', event.miPushRegId);
    emit(state.copyWith(
      miPushRegId: event.miPushRegId,
    ));
  }

  FutureOr<void> _onCommentDescendingChanged(
      CommentDescendingChanged event, Emitter<AppPreferencesState> emit) async {
    final prefs = await _prefs;
    await prefs.setString('commentDescending', event.descending.toString());
    emit(state.copyWith(
      commentDescending: event.descending,
    ));
  }

  FutureOr<void> _onThemeModeChanged(
      ThemeModeChanged event, Emitter<AppPreferencesState> emit) async {
    final prefs = await _prefs;
    await prefs.setString(
      'themeMode',
      EnumToString.convertToString(event.themeMode),
    );
    emit(state.copyWith(
      themeMode: event.themeMode,
    ));
  }
}
