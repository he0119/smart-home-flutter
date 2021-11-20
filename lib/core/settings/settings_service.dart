import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smarthome/core/core.dart';
import 'package:smarthome/user/model/user.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<ThemeMode> themeMode() async {
    final prefs = await _prefs;
    final String themeModeString = prefs.getString('themeMode') ?? '';
    return EnumToString.fromString(ThemeMode.values, themeModeString) ??
        ThemeMode.system;
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    final prefs = await _prefs;
    prefs.setString('themeMode', EnumToString.convertToString(theme));
  }

  Future<String?> apiUrl() async {
    final prefs = await _prefs;
    return prefs.getString('apiUrl');
  }

  Future<void> updateApiUrl(String url) async {
    final prefs = await _prefs;
    prefs.setString('apiUrl', url);
  }

  Future<String?> miPushAppId() async {
    final prefs = await _prefs;
    return prefs.getString('miPushAppId');
  }

  Future<void> updateMiPushAppId(String appId) async {
    final prefs = await _prefs;
    prefs.setString('miPushAppId', appId);
  }

  Future<String?> miPushAppKey() async {
    final prefs = await _prefs;
    return prefs.getString('miPushAppKey');
  }

  Future<void> updateMiPushAppKey(String appKey) async {
    final prefs = await _prefs;
    prefs.setString('miPushAppKey', appKey);
  }

  Future<String?> miPushRegId() async {
    final prefs = await _prefs;
    return prefs.getString('miPushRegId');
  }

  Future<void> updateMiPushRegId(String regId) async {
    final prefs = await _prefs;
    prefs.setString('miPushRegId', regId);
  }

  Future<int> refreshInterval() async {
    final prefs = await _prefs;
    return prefs.getInt('refreshInterval') ?? 10;
  }

  Future<void> updateRefreshInterval(int interval) async {
    final prefs = await _prefs;
    prefs.setInt('refreshInterval', interval);
  }

  Future<String?> adminUrl() async {
    final prefs = await _prefs;
    return prefs.getString('adminUrl');
  }

  Future<void> updateAdminUrl(String url) async {
    final prefs = await _prefs;
    prefs.setString('adminUrl', url);
  }

  Future<String> blogUrl() async {
    final prefs = await _prefs;
    return prefs.getString('blogUrl') ?? 'https://hehome.xyz';
  }

  Future<void> updateBlogUrl(String url) async {
    final prefs = await _prefs;
    prefs.setString('blogUrl', url);
  }

  Future<String?> blogAdminUrl() async {
    final prefs = await _prefs;
    return prefs.getString('blogAdminUrl');
  }

  Future<void> updateBlogAdminUrl(String url) async {
    final prefs = await _prefs;
    prefs.setString('blogAdminUrl', url);
  }

  Future<AppTab> defaultPage() async {
    final prefs = await _prefs;
    final String defaultPageString = prefs.getString('defaultPage') ?? '';
    return EnumToString.fromString(AppTab.values, defaultPageString) ??
        AppTab.storage;
  }

  Future<void> updateDefaultPage(AppTab page) async {
    final prefs = await _prefs;
    prefs.setString('defaultPage', EnumToString.convertToString(page));
  }

  Future<User?> loginUser() async {
    final prefs = await _prefs;
    final String? userString = prefs.getString('loginUser');
    if (userString == null) {
      return null;
    }
    return User.fromJson(jsonDecode(userString));
  }

  Future<void> updateLoginUser(User? user) async {
    final prefs = await _prefs;
    if (user == null) {
      prefs.remove('loginUser');
    } else {
      prefs.setString('loginUser', jsonEncode(user.toJson()));
    }
  }

  Future<bool> commentDescending() async {
    final prefs = await _prefs;
    return prefs.getBool('commentDescending') ?? false;
  }

  Future<void> updateCommentDescending(bool descending) async {
    final prefs = await _prefs;
    prefs.setBool('commentDescending', descending);
  }
}
