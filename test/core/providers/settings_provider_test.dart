import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/model/app_config.dart';
import 'package:smarthome/core/model/app_tab.dart';
import 'package:smarthome/core/providers/settings_provider.dart';
import 'package:smarthome/user/model/user.dart';

import '../../mocks/mocks.mocks.dart';

void main() {
  late MockSettingsRepository mockSettingsRepository;
  late AppConfig testAppConfig;

  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    testAppConfig = AppConfig(
      appName: 'Test',
      flavorName: 'test',
      defaultApiUrl: 'http://test.com',
      defaultAdminUrl: 'http://admin.test.com',
    );
  });

  ProviderContainer setupContainer() {
    return ProviderContainer.test(
      overrides: [
        settingsServiceProvider.overrideWithValue(mockSettingsRepository),
        appConfigProvider.overrideWithValue(testAppConfig),
      ],
    );
  }

  void setupDefaultMocks() {
    when(mockSettingsRepository.loginUser()).thenAnswer((_) async => null);
    when(
      mockSettingsRepository.themeMode(),
    ).thenAnswer((_) async => ThemeMode.system);
    when(
      mockSettingsRepository.defaultPage(),
    ).thenAnswer((_) async => AppTab.storage);
    when(mockSettingsRepository.apiUrl()).thenAnswer((_) async => null);
    when(mockSettingsRepository.adminUrl()).thenAnswer((_) async => null);
    when(
      mockSettingsRepository.blogUrl(),
    ).thenAnswer((_) async => 'http://blog.test.com');
    when(mockSettingsRepository.blogAdminUrl()).thenAnswer((_) async => null);
    when(mockSettingsRepository.miPushAppId()).thenAnswer((_) async => null);
    when(mockSettingsRepository.miPushAppKey()).thenAnswer((_) async => null);
    when(mockSettingsRepository.miPushRegId()).thenAnswer((_) async => null);
    when(mockSettingsRepository.refreshInterval()).thenAnswer((_) async => 30);
    when(
      mockSettingsRepository.commentDescending(),
    ).thenAnswer((_) async => false);
    when(mockSettingsRepository.cookies()).thenAnswer((_) async => null);
    when(mockSettingsRepository.loginMethod()).thenAnswer((_) async => null);
  }

  group('SettingsNotifier', () {
    test('loadSettings 应该加载所有设置', () async {
      final container = setupContainer();
      setupDefaultMocks();

      await container.read(settingsProvider.notifier).loadSettings();

      final settings = container.read(settingsProvider);
      expect(settings.loginUser, null);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.defaultPage, AppTab.storage);
      expect(settings.apiUrl, null);
      expect(settings.adminUrl, 'http://admin.test.com');
      expect(settings.blogUrl, 'http://blog.test.com');
      expect(settings.refreshInterval, 30);
      expect(settings.commentDescending, false);
      expect(settings.isLogin, false);
    });

    test('loadSettings 应该加载登录用户', () async {
      final testUser = const User(
        username: 'testuser',
        email: 'test@example.com',
      );

      final container = setupContainer();
      setupDefaultMocks();
      when(
        mockSettingsRepository.loginUser(),
      ).thenAnswer((_) async => testUser);

      await container.read(settingsProvider.notifier).loadSettings();

      final settings = container.read(settingsProvider);
      expect(settings.loginUser, testUser);
      expect(settings.isLogin, true);
    });

    test('updateThemeMode 应该更新主题模式', () async {
      final container = setupContainer();
      setupDefaultMocks();
      when(
        mockSettingsRepository.updateThemeMode(any),
      ).thenAnswer((_) async => {});

      await container.read(settingsProvider.notifier).loadSettings();

      await container
          .read(settingsProvider.notifier)
          .updateThemeMode(ThemeMode.dark);

      final settings = container.read(settingsProvider);
      expect(settings.themeMode, ThemeMode.dark);
      verify(mockSettingsRepository.updateThemeMode(ThemeMode.dark)).called(1);
    });

    test('updateLoginUser 应该更新登录用户', () async {
      final testUser = const User(
        username: 'testuser',
        email: 'test@example.com',
      );

      final container = setupContainer();
      setupDefaultMocks();
      when(
        mockSettingsRepository.updateLoginUser(any),
      ).thenAnswer((_) async => {});

      await container.read(settingsProvider.notifier).loadSettings();

      await container.read(settingsProvider.notifier).updateLoginUser(testUser);

      final settings = container.read(settingsProvider);
      expect(settings.loginUser, testUser);
      expect(settings.isLogin, true);
      verify(mockSettingsRepository.updateLoginUser(testUser)).called(1);
    });

    test('updateApiUrl 应该更新 API URL', () async {
      final container = setupContainer();
      setupDefaultMocks();
      when(
        mockSettingsRepository.updateApiUrl(any),
      ).thenAnswer((_) async => {});

      await container.read(settingsProvider.notifier).loadSettings();

      const newUrl = 'http://new-api.test.com';
      await container.read(settingsProvider.notifier).updateApiUrl(newUrl);

      final settings = container.read(settingsProvider);
      expect(settings.apiUrl, newUrl);
      verify(mockSettingsRepository.updateApiUrl(newUrl)).called(1);
    });

    test('updateDefaultPage 应该更新默认页面', () async {
      final container = setupContainer();
      setupDefaultMocks();
      when(
        mockSettingsRepository.updateDefaultPage(any),
      ).thenAnswer((_) async => {});

      await container.read(settingsProvider.notifier).loadSettings();

      await container
          .read(settingsProvider.notifier)
          .updateDefaultPage(AppTab.board);

      final settings = container.read(settingsProvider);
      expect(settings.defaultPage, AppTab.board);
      verify(mockSettingsRepository.updateDefaultPage(AppTab.board)).called(1);
    });

    test('updateRefreshInterval 应该更新刷新间隔', () async {
      final container = setupContainer();
      setupDefaultMocks();
      when(
        mockSettingsRepository.updateRefreshInterval(any),
      ).thenAnswer((_) async => {});

      await container.read(settingsProvider.notifier).loadSettings();

      await container.read(settingsProvider.notifier).updateRefreshInterval(60);

      final settings = container.read(settingsProvider);
      expect(settings.refreshInterval, 60);
      verify(mockSettingsRepository.updateRefreshInterval(60)).called(1);
    });

    test('updateCommentDescending 应该更新评论排序', () async {
      final container = setupContainer();
      setupDefaultMocks();
      when(
        mockSettingsRepository.updateCommentDescending(any),
      ).thenAnswer((_) async => {});

      await container.read(settingsProvider.notifier).loadSettings();

      await container
          .read(settingsProvider.notifier)
          .updateCommentDescending(true);

      final settings = container.read(settingsProvider);
      expect(settings.commentDescending, true);
      verify(mockSettingsRepository.updateCommentDescending(true)).called(1);
    });

    test('updateMiPushAppId 应该更新小米推送 App ID', () async {
      final container = setupContainer();
      setupDefaultMocks();
      when(
        mockSettingsRepository.updateMiPushAppId(any),
      ).thenAnswer((_) async => {});

      await container.read(settingsProvider.notifier).loadSettings();

      const newAppId = 'new-app-id';
      await container
          .read(settingsProvider.notifier)
          .updateMiPushAppId(newAppId);

      final settings = container.read(settingsProvider);
      expect(settings.miPushAppId, newAppId);
      verify(mockSettingsRepository.updateMiPushAppId(newAppId)).called(1);
    });

    test('updateMiPushAppKey 应该更新小米推送 App Key', () async {
      final container = setupContainer();
      setupDefaultMocks();
      when(
        mockSettingsRepository.updateMiPushAppKey(any),
      ).thenAnswer((_) async => {});

      await container.read(settingsProvider.notifier).loadSettings();

      const newAppKey = 'new-app-key';
      await container
          .read(settingsProvider.notifier)
          .updateMiPushAppKey(newAppKey);

      final settings = container.read(settingsProvider);
      expect(settings.miPushAppKey, newAppKey);
      verify(mockSettingsRepository.updateMiPushAppKey(newAppKey)).called(1);
    });

    test('updateMiPushRegId 应该更新小米推送 Reg ID', () async {
      final container = setupContainer();
      setupDefaultMocks();
      when(
        mockSettingsRepository.updateMiPushRegId(any),
      ).thenAnswer((_) async => {});

      await container.read(settingsProvider.notifier).loadSettings();

      const newRegId = 'new-reg-id';
      await container
          .read(settingsProvider.notifier)
          .updateMiPushRegId(newRegId);

      final settings = container.read(settingsProvider);
      expect(settings.miPushRegId, newRegId);
      verify(mockSettingsRepository.updateMiPushRegId(newRegId)).called(1);
    });

    test('updateAdminUrl 应该更新管理页面 URL', () async {
      final container = setupContainer();
      setupDefaultMocks();
      when(
        mockSettingsRepository.updateAdminUrl(any),
      ).thenAnswer((_) async => {});

      await container.read(settingsProvider.notifier).loadSettings();

      const newAdminUrl = 'http://new-admin.test.com';
      await container
          .read(settingsProvider.notifier)
          .updateAdminUrl(newAdminUrl);

      final settings = container.read(settingsProvider);
      expect(settings.adminUrl, newAdminUrl);
      verify(mockSettingsRepository.updateAdminUrl(newAdminUrl)).called(1);
    });

    test('updateBlogUrl 应该更新博客 URL', () async {
      final container = setupContainer();
      setupDefaultMocks();
      when(
        mockSettingsRepository.updateBlogUrl(any),
      ).thenAnswer((_) async => {});

      await container.read(settingsProvider.notifier).loadSettings();

      const newBlogUrl = 'http://new-blog.test.com';
      await container.read(settingsProvider.notifier).updateBlogUrl(newBlogUrl);

      final settings = container.read(settingsProvider);
      expect(settings.blogUrl, newBlogUrl);
      verify(mockSettingsRepository.updateBlogUrl(newBlogUrl)).called(1);
    });

    test('updateBlogAdminUrl 应该更新博客管理页面 URL', () async {
      final container = setupContainer();
      setupDefaultMocks();
      when(
        mockSettingsRepository.updateBlogAdminUrl(any),
      ).thenAnswer((_) async => {});

      await container.read(settingsProvider.notifier).loadSettings();

      const newBlogAdminUrl = 'http://new-blog-admin.test.com';
      await container
          .read(settingsProvider.notifier)
          .updateBlogAdminUrl(newBlogAdminUrl);

      final settings = container.read(settingsProvider);
      expect(settings.blogAdminUrl, newBlogAdminUrl);
      verify(
        mockSettingsRepository.updateBlogAdminUrl(newBlogAdminUrl),
      ).called(1);
    });

    test('updateCookies 应该更新 Cookies', () async {
      final container = setupContainer();
      setupDefaultMocks();
      when(
        mockSettingsRepository.updateCookies(any),
      ).thenAnswer((_) async => {});

      await container.read(settingsProvider.notifier).loadSettings();

      const newCookies = 'session=xyz123';
      await container.read(settingsProvider.notifier).updateCookies(newCookies);

      final settings = container.read(settingsProvider);
      expect(settings.cookies, newCookies);
      verify(mockSettingsRepository.updateCookies(newCookies)).called(1);
    });

    test('updateLoginMethod 应该更新登录方法', () async {
      final container = setupContainer();
      setupDefaultMocks();
      when(
        mockSettingsRepository.updateLoginMethod(any),
      ).thenAnswer((_) async => {});

      await container.read(settingsProvider.notifier).loadSettings();

      const newLoginMethod = 'oidc';
      await container
          .read(settingsProvider.notifier)
          .updateLoginMethod(newLoginMethod);

      final settings = container.read(settingsProvider);
      expect(settings.loginMethod, newLoginMethod);
      verify(
        mockSettingsRepository.updateLoginMethod(newLoginMethod),
      ).called(1);
    });

    test('相同值不应该触发更新', () async {
      final container = setupContainer();
      setupDefaultMocks();
      when(
        mockSettingsRepository.updateThemeMode(any),
      ).thenAnswer((_) async => {});

      await container.read(settingsProvider.notifier).loadSettings();

      // 尝试更新为相同的值
      await container
          .read(settingsProvider.notifier)
          .updateThemeMode(ThemeMode.system);

      // 不应该调用 repository 的更新方法
      verifyNever(mockSettingsRepository.updateThemeMode(ThemeMode.system));
    });
  });
}
