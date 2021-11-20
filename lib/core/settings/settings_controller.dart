import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:smarthome/core/model/app_config.dart';
import 'package:smarthome/core/model/app_tab.dart';
import 'package:smarthome/user/model/user.dart';

import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(
    this._settingsService,
    this.appConfig,
  );

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService _settingsService;

  // 应用的默认配置
  final AppConfig appConfig;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late User? _loginUser;
  late ThemeMode _themeMode;
  late AppTab _defaultPage;
  late String _apiUrl;
  late String _adminUrl;
  late String _blogUrl;
  late String? _blogAdminUrl;
  late String? _miPushAppId;
  late String? _miPushAppKey;
  late String? _miPushRegId;
  late int _refreshInterval;
  late bool _commentDescending;

  // 判断是否登录
  bool get isLogin => _loginUser != null;

  // Allow Widgets to read the user's settings.
  User? get loginUser => _loginUser;
  ThemeMode get themeMode => _themeMode;
  AppTab get defaultPage => _defaultPage;
  String get apiUrl => _apiUrl;
  String get adminUrl => _adminUrl;
  String get blogUrl => _blogUrl;
  String? get blogAdminUrl => _blogAdminUrl;
  String? get miPushAppId => _miPushAppId;
  String? get miPushAppKey => _miPushAppKey;
  String? get miPushRegId => _miPushRegId;
  int get refreshInterval => _refreshInterval;
  bool get commentDescending => _commentDescending;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    _loginUser = await _settingsService.loginUser();
    _themeMode = await _settingsService.themeMode();
    _defaultPage = await _settingsService.defaultPage();
    _apiUrl = await _settingsService.apiUrl() ?? appConfig.defaultApiUrl;
    _adminUrl = await _settingsService.adminUrl() ?? appConfig.defaultAdminUrl;
    _blogUrl = await _settingsService.blogUrl();
    _blogAdminUrl = await _settingsService.blogAdminUrl();
    _miPushAppId = await _settingsService.miPushAppId();
    _miPushAppKey = await _settingsService.miPushAppKey();
    _miPushRegId = await _settingsService.miPushRegId();
    _refreshInterval = await _settingsService.refreshInterval();
    _commentDescending = await _settingsService.commentDescending();
    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Dot not perform any work if new and old ThemeMode are identical
    if (newThemeMode == _themeMode) return;

    // Otherwise, store the new theme mode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updateLoginUser(User? newLoginUser) async {
    if (newLoginUser == _loginUser) return;

    _loginUser = newLoginUser;

    notifyListeners();

    await _settingsService.updateLoginUser(newLoginUser);
  }

  Future<void> updateApiUrl(String? newApiUrl) async {
    if (newApiUrl == null) return;

    if (newApiUrl == _apiUrl) return;

    _apiUrl = newApiUrl;

    notifyListeners();

    await _settingsService.updateApiUrl(newApiUrl);
  }

  Future<void> updateMiPushAppId(String? newMiPushAppId) async {
    if (newMiPushAppId == null) return;

    if (newMiPushAppId == _miPushAppId) return;

    _miPushAppId = newMiPushAppId;

    notifyListeners();

    await _settingsService.updateMiPushAppId(newMiPushAppId);
  }

  Future<void> updateMiPushAppKey(String? newMiPushAppKey) async {
    if (newMiPushAppKey == null) return;

    if (newMiPushAppKey == _miPushAppKey) return;

    _miPushAppKey = newMiPushAppKey;

    notifyListeners();

    await _settingsService.updateMiPushAppKey(newMiPushAppKey);
  }

  Future<void> updateMiPushRegId(String? newMiPushRegId) async {
    if (newMiPushRegId == null) return;

    if (newMiPushRegId == _miPushRegId) return;

    _miPushRegId = newMiPushRegId;

    notifyListeners();

    await _settingsService.updateMiPushRegId(newMiPushRegId);
  }

  Future<void> updateRefreshInterval(int? newRefreshInterval) async {
    if (newRefreshInterval == null) return;

    if (newRefreshInterval == _refreshInterval) return;

    _refreshInterval = newRefreshInterval;

    notifyListeners();

    await _settingsService.updateRefreshInterval(newRefreshInterval);
  }

  Future<void> updateAdminUrl(String? newAdminUrl) async {
    if (newAdminUrl == null) return;

    if (newAdminUrl == _adminUrl) return;

    _adminUrl = newAdminUrl;

    notifyListeners();

    await _settingsService.updateAdminUrl(newAdminUrl);
  }

  Future<void> updateBlogUrl(String? newBlogUrl) async {
    if (newBlogUrl == null) return;

    if (newBlogUrl == _blogUrl) return;

    _blogUrl = newBlogUrl;

    notifyListeners();

    await _settingsService.updateBlogUrl(newBlogUrl);
  }

  Future<void> updateBlogAdminUrl(String? newBlogAdminUrl) async {
    if (newBlogAdminUrl == null) return;

    if (newBlogAdminUrl == _blogAdminUrl) return;

    _blogAdminUrl = newBlogAdminUrl;

    notifyListeners();

    await _settingsService.updateBlogAdminUrl(newBlogAdminUrl);
  }

  Future<void> updateDefaultPage(AppTab? newDefaultPage) async {
    if (newDefaultPage == null) return;

    if (newDefaultPage == _defaultPage) return;

    _defaultPage = newDefaultPage;

    notifyListeners();

    await _settingsService.updateDefaultPage(newDefaultPage);
  }

  Future<void> updateCommentDescending(bool? newCommentDescending) async {
    if (newCommentDescending == null) return;

    if (newCommentDescending == _commentDescending) return;

    _commentDescending = newCommentDescending;

    notifyListeners();

    await _settingsService.updateCommentDescending(newCommentDescending);
  }
}
