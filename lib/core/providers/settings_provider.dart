import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/app/settings/settings_service.dart';
import 'package:smarthome/core/model/app_config.dart';
import 'package:smarthome/core/model/app_tab.dart';
import 'package:smarthome/user/model/user.dart';

/// Settings state class
class SettingsState {
  final User? loginUser;
  final ThemeMode themeMode;
  final AppTab defaultPage;
  final String? apiUrl;
  final String adminUrl;
  final String blogUrl;
  final String? blogAdminUrl;
  final String? miPushAppId;
  final String? miPushAppKey;
  final String? miPushRegId;
  final int refreshInterval;
  final bool commentDescending;
  final String? cookies;
  final String? loginMethod;
  final AppConfig appConfig;

  const SettingsState({
    this.loginUser,
    required this.themeMode,
    required this.defaultPage,
    this.apiUrl,
    required this.adminUrl,
    required this.blogUrl,
    this.blogAdminUrl,
    this.miPushAppId,
    this.miPushAppKey,
    this.miPushRegId,
    required this.refreshInterval,
    required this.commentDescending,
    this.cookies,
    this.loginMethod,
    required this.appConfig,
  });

  bool get isLogin => loginUser != null;

  SettingsState copyWith({
    User? Function()? loginUser,
    ThemeMode? themeMode,
    AppTab? defaultPage,
    String? Function()? apiUrl,
    String? adminUrl,
    String? blogUrl,
    String? Function()? blogAdminUrl,
    String? Function()? miPushAppId,
    String? Function()? miPushAppKey,
    String? Function()? miPushRegId,
    int? refreshInterval,
    bool? commentDescending,
    String? Function()? cookies,
    String? Function()? loginMethod,
    AppConfig? appConfig,
  }) {
    return SettingsState(
      loginUser: loginUser != null ? loginUser() : this.loginUser,
      themeMode: themeMode ?? this.themeMode,
      defaultPage: defaultPage ?? this.defaultPage,
      apiUrl: apiUrl != null ? apiUrl() : this.apiUrl,
      adminUrl: adminUrl ?? this.adminUrl,
      blogUrl: blogUrl ?? this.blogUrl,
      blogAdminUrl: blogAdminUrl != null ? blogAdminUrl() : this.blogAdminUrl,
      miPushAppId: miPushAppId != null ? miPushAppId() : this.miPushAppId,
      miPushAppKey: miPushAppKey != null ? miPushAppKey() : this.miPushAppKey,
      miPushRegId: miPushRegId != null ? miPushRegId() : this.miPushRegId,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      commentDescending: commentDescending ?? this.commentDescending,
      cookies: cookies != null ? cookies() : this.cookies,
      loginMethod: loginMethod != null ? loginMethod() : this.loginMethod,
      appConfig: appConfig ?? this.appConfig,
    );
  }
}

/// Settings Notifier
class SettingsNotifier extends Notifier<SettingsState> {
  SettingsService get _settingsService => ref.read(settingsServiceProvider);
  AppConfig get _appConfig => ref.read(appConfigProvider);

  @override
  SettingsState build() {
    // This will be initialized later in loadSettings
    // Return a default state for now
    throw UnimplementedError('Call loadSettings first');
  }

  Future<void> loadSettings() async {
    final loginUser = await _settingsService.loginUser();
    final themeMode = await _settingsService.themeMode();
    final defaultPage = await _settingsService.defaultPage();
    final apiUrl = await _settingsService.apiUrl();
    final adminUrl =
        await _settingsService.adminUrl() ?? _appConfig.defaultAdminUrl;
    final blogUrl = await _settingsService.blogUrl();
    final blogAdminUrl = await _settingsService.blogAdminUrl();
    final miPushAppId = await _settingsService.miPushAppId();
    final miPushAppKey = await _settingsService.miPushAppKey();
    final miPushRegId = await _settingsService.miPushRegId();
    final refreshInterval = await _settingsService.refreshInterval();
    final commentDescending = await _settingsService.commentDescending();
    final cookies = await _settingsService.cookies();
    final loginMethod = await _settingsService.loginMethod();

    state = SettingsState(
      loginUser: loginUser,
      themeMode: themeMode,
      defaultPage: defaultPage,
      apiUrl: apiUrl,
      adminUrl: adminUrl,
      blogUrl: blogUrl,
      blogAdminUrl: blogAdminUrl,
      miPushAppId: miPushAppId,
      miPushAppKey: miPushAppKey,
      miPushRegId: miPushRegId,
      refreshInterval: refreshInterval,
      commentDescending: commentDescending,
      cookies: cookies,
      loginMethod: loginMethod,
      appConfig: _appConfig,
    );
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == state.themeMode) return;
    state = state.copyWith(themeMode: newThemeMode);
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updateLoginUser(User? newLoginUser) async {
    state = state.copyWith(loginUser: () => newLoginUser);
    await _settingsService.updateLoginUser(newLoginUser);
  }

  Future<void> updateApiUrl(String? newApiUrl) async {
    if (newApiUrl == null || newApiUrl == state.apiUrl) return;
    state = state.copyWith(apiUrl: () => newApiUrl);
    await _settingsService.updateApiUrl(newApiUrl);
  }

  Future<void> updateMiPushAppId(String? newMiPushAppId) async {
    if (newMiPushAppId == null || newMiPushAppId == state.miPushAppId) return;
    state = state.copyWith(miPushAppId: () => newMiPushAppId);
    await _settingsService.updateMiPushAppId(newMiPushAppId);
  }

  Future<void> updateMiPushAppKey(String? newMiPushAppKey) async {
    if (newMiPushAppKey == null || newMiPushAppKey == state.miPushAppKey) {
      return;
    }
    state = state.copyWith(miPushAppKey: () => newMiPushAppKey);
    await _settingsService.updateMiPushAppKey(newMiPushAppKey);
  }

  Future<void> updateMiPushRegId(String? newMiPushRegId) async {
    if (newMiPushRegId == null || newMiPushRegId == state.miPushRegId) return;
    state = state.copyWith(miPushRegId: () => newMiPushRegId);
    await _settingsService.updateMiPushRegId(newMiPushRegId);
  }

  Future<void> updateRefreshInterval(int? newRefreshInterval) async {
    if (newRefreshInterval == null ||
        newRefreshInterval == state.refreshInterval) {
      return;
    }
    state = state.copyWith(refreshInterval: newRefreshInterval);
    await _settingsService.updateRefreshInterval(newRefreshInterval);
  }

  Future<void> updateAdminUrl(String? newAdminUrl) async {
    if (newAdminUrl == null || newAdminUrl == state.adminUrl) return;
    state = state.copyWith(adminUrl: newAdminUrl);
    await _settingsService.updateAdminUrl(newAdminUrl);
  }

  Future<void> updateBlogUrl(String? newBlogUrl) async {
    if (newBlogUrl == null || newBlogUrl == state.blogUrl) return;
    state = state.copyWith(blogUrl: newBlogUrl);
    await _settingsService.updateBlogUrl(newBlogUrl);
  }

  Future<void> updateBlogAdminUrl(String? newBlogAdminUrl) async {
    if (newBlogAdminUrl == null || newBlogAdminUrl == state.blogAdminUrl) {
      return;
    }
    state = state.copyWith(blogAdminUrl: () => newBlogAdminUrl);
    await _settingsService.updateBlogAdminUrl(newBlogAdminUrl);
  }

  Future<void> updateDefaultPage(AppTab? newDefaultPage) async {
    if (newDefaultPage == null || newDefaultPage == state.defaultPage) return;
    state = state.copyWith(defaultPage: newDefaultPage);
    await _settingsService.updateDefaultPage(newDefaultPage);
  }

  Future<void> updateCommentDescending(bool? newCommentDescending) async {
    if (newCommentDescending == null ||
        newCommentDescending == state.commentDescending) {
      return;
    }
    state = state.copyWith(commentDescending: newCommentDescending);
    await _settingsService.updateCommentDescending(newCommentDescending);
  }

  Future<void> updateCookies(String newCookies) async {
    if (newCookies == state.cookies) return;
    state = state.copyWith(cookies: () => newCookies);
    await _settingsService.updateCookies(newCookies);
  }

  Future<void> updateLoginMethod(String? newLoginMethod) async {
    if (newLoginMethod == null || newLoginMethod == state.loginMethod) return;
    state = state.copyWith(loginMethod: () => newLoginMethod);
    await _settingsService.updateLoginMethod(newLoginMethod);
  }
}

/// Internal providers for dependencies (exported for bootstrap)
final settingsServiceProvider = Provider<SettingsService>(
  (ref) => throw UnimplementedError('Override in main'),
);

final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('Override in main'),
);

/// Settings provider
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
