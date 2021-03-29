import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthome/core/model/models.dart';
import 'package:smarthome/user/user.dart';

part 'app_preferences_event.dart';
part 'app_preferences_state.dart';

class AppPreferencesBloc
    extends Bloc<AppPreferencesEvent, AppPreferencesState> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  AppPreferencesBloc() : super(AppPreferencesState.initial());

  @override
  Stream<AppPreferencesState> mapEventToState(
    AppPreferencesEvent event,
  ) async* {
    if (event is AppStarted) {
      final prefs = await _prefs;
      final apiUrl = prefs.getString('apiUrl');
      final miPushAppId = prefs.getString('miPushAppId');
      final miPushAppKey = prefs.getString('miPushAppKey');
      final miPushRegId = prefs.getString('miPushRegId');
      final refreshInterval = prefs.getInt('refreshInterval');
      final blogUrl = prefs.getString('blogUrl');
      final blogAdminUrl = prefs.getString('blogAdminUrl');
      final defaultPageString = prefs.getString('defaultPage');
      AppTab? defaultPage;
      if (defaultPageString != null) {
        defaultPage = EnumToString.fromString(AppTab.values, defaultPageString);
      }
      final loginUserJsonString = prefs.getString('loginUser');
      final loginUser = loginUserJsonString != null
          ? User.fromJson(jsonDecode(loginUserJsonString))
          : null;
      final commentDescending =
          prefs.getString('commentDescending')?.toLowerCase() == 'true';
      yield state.copyWith(
        initialized: true,
        apiUrl: apiUrl,
        miPushAppId: miPushAppId,
        miPushAppKey: miPushAppKey,
        miPushRegId: miPushRegId,
        refreshInterval: refreshInterval,
        blogUrl: blogUrl,
        blogAdminUrl: blogAdminUrl,
        defaultPage: defaultPage,
        loginUser: loginUser,
        commentDescending: commentDescending,
      );
    }
    if (event is AppApiUrlChanged) {
      final prefs = await _prefs;
      await prefs.setString('apiUrl', event.apiUrl);
      yield state.copyWith(apiUrl: event.apiUrl);
    }
    if (event is AppIotRefreshIntervalChanged) {
      final prefs = await _prefs;
      await prefs.setInt('refreshInterval', event.interval);
      yield state.copyWith(refreshInterval: event.interval);
    }
    if (event is AppBlogUrlChanged) {
      final prefs = await _prefs;
      await prefs.setString('blogUrl', event.blogUrl);
      await prefs.setString('blogAdminUrl', event.blogAdminUrl);
      yield state.copyWith(
        blogUrl: event.blogUrl,
        blogAdminUrl: event.blogAdminUrl,
      );
    }
    if (event is DefaultPageChanged) {
      final prefs = await _prefs;
      await prefs.setString(
        'defaultPage',
        EnumToString.convertToString(event.defaultPage),
      );
      yield state.copyWith(
        defaultPage: event.defaultPage,
      );
    }
    if (event is LoginUserChanged) {
      final prefs = await _prefs;
      await prefs.setString('loginUser', jsonEncode(event.loginUser.toJson()));
      yield state.copyWith(
        loginUser: event.loginUser,
      );
    }
    if (event is MiPushKeyChanged) {
      final prefs = await _prefs;
      await prefs.setString('miPushAppId', event.miPushAppId);
      await prefs.setString('miPushAppKey', event.miPushAppKey);
      yield state.copyWith(
        miPushAppId: event.miPushAppId,
        miPushAppKey: event.miPushAppKey,
      );
    }
    if (event is MiPushRegIdChanged) {
      final prefs = await _prefs;
      await prefs.setString('miPushRegId', event.miPushRegId);
      yield state.copyWith(
        miPushRegId: event.miPushRegId,
      );
    }
    if (event is CommentDescendingChanged) {
      final prefs = await _prefs;
      await prefs.setString('commentDescending', event.descending.toString());
      yield state.copyWith(
        commentDescending: event.descending,
      );
    }
  }
}
