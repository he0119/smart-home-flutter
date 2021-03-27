import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthome/app/model/app_tab.dart';
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
      try {
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
          defaultPage =
              EnumToString.fromString(AppTab.values, defaultPageString);
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
        prefs.setString(
          'defaultPage',
          EnumToString.convertToString(event.defaultPage),
        );
        yield state.copyWith(
          defaultPage: event.defaultPage,
        );
      } catch (e) {
        _log.severe('设置默认主页失败');
      }
    }
    if (event is LoginUserChanged) {
      try {
        final SharedPreferences prefs = await _prefs;
        prefs.setString('loginUser', jsonEncode(event.loginUser.toJson()));
        yield state.copyWith(
          loginUser: event.loginUser,
        );
      } catch (e) {
        _log.severe('设置登录用户失败');
      }
    }
    if (event is MiPushKeyChanged) {
      try {
        final SharedPreferences prefs = await _prefs;
        prefs.setString('miPushAppId', event.miPushAppId);
        prefs.setString('miPushAppKey', event.miPushAppKey);
        yield state.copyWith(
          miPushAppId: event.miPushAppId,
          miPushAppKey: event.miPushAppKey,
        );
      } catch (e) {
        _log.severe('设置小米推送密钥失败');
      }
    }
    if (event is MiPushRegIdChanged) {
      try {
        final SharedPreferences prefs = await _prefs;
        prefs.setString('miPushRegId', event.miPushRegId);
        yield state.copyWith(
          miPushRegId: event.miPushRegId,
        );
      } catch (e) {
        _log.severe('设置小米推送注册标识符失败');
      }
    }
    if (event is CommentDescendingChanged) {
      try {
        final SharedPreferences prefs = await _prefs;
        prefs.setString('commentDescending', event.descending.toString());
        yield state.copyWith(
          commentDescending: event.descending,
        );
      } catch (e) {
        _log.severe('设置评论排序方式失败');
      }
    }
  }
}
