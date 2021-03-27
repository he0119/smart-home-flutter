import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthome/core/model/models.dart';
import 'package:smarthome/user/user.dart';

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
      final SharedPreferences prefs = await _prefs;
      String? apiUrl = prefs.getString('apiUrl');
      String? miPushAppId = prefs.getString('miPushAppId');
      String? miPushAppKey = prefs.getString('miPushAppKey');
      String? miPushRegId = prefs.getString('miPushRegId');
      int? refreshInterval = prefs.getInt('refreshInterval');
      String? blogUrl = prefs.getString('blogUrl');
      String? blogAdminUrl = prefs.getString('blogAdminUrl');
      String? defaultPageString = prefs.getString('defaultPage');
      AppTab? defaultPage;
      if (defaultPageString != null) {
        defaultPage = EnumToString.fromString(AppTab.values, defaultPageString);
      }
      String? loginUserJsonString = prefs.getString('loginUser');
      User? loginUser = loginUserJsonString != null
          ? User.fromJson(jsonDecode(loginUserJsonString))
          : null;
      bool commentDescending =
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
      final SharedPreferences prefs = await _prefs;
      prefs.setString('apiUrl', event.apiUrl);
      yield state.copyWith(apiUrl: event.apiUrl);
    }
    if (event is AppIotRefreshIntervalChanged) {
      final SharedPreferences prefs = await _prefs;
      prefs.setInt('refreshInterval', event.interval);
      yield state.copyWith(refreshInterval: event.interval);
    }
    if (event is AppBlogUrlChanged) {
      final SharedPreferences prefs = await _prefs;
      prefs.setString('blogUrl', event.blogUrl);
      prefs.setString('blogAdminUrl', event.blogAdminUrl);
      yield state.copyWith(
        blogUrl: event.blogUrl,
        blogAdminUrl: event.blogAdminUrl,
      );
    }
    if (event is DefaultPageChanged) {
      final SharedPreferences prefs = await _prefs;
      prefs.setString(
        'defaultPage',
        EnumToString.convertToString(event.defaultPage),
      );
      yield state.copyWith(
        defaultPage: event.defaultPage,
      );
    }
    if (event is LoginUserChanged) {
      final SharedPreferences prefs = await _prefs;
      prefs.setString('loginUser', jsonEncode(event.loginUser.toJson()));
      yield state.copyWith(
        loginUser: event.loginUser,
      );
    }
    if (event is MiPushKeyChanged) {
      final SharedPreferences prefs = await _prefs;
      prefs.setString('miPushAppId', event.miPushAppId);
      prefs.setString('miPushAppKey', event.miPushAppKey);
      yield state.copyWith(
        miPushAppId: event.miPushAppId,
        miPushAppKey: event.miPushAppKey,
      );
    }
    if (event is MiPushRegIdChanged) {
      final SharedPreferences prefs = await _prefs;
      prefs.setString('miPushRegId', event.miPushRegId);
      yield state.copyWith(
        miPushRegId: event.miPushRegId,
      );
    }
    if (event is CommentDescendingChanged) {
      final SharedPreferences prefs = await _prefs;
      prefs.setString('commentDescending', event.descending.toString());
      yield state.copyWith(
        commentDescending: event.descending,
      );
    }
  }
}
