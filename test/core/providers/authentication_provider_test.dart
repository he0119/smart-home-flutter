import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/model/app_config.dart';
import 'package:smarthome/core/model/app_tab.dart';
import 'package:smarthome/core/providers/authentication_provider.dart';
import 'package:smarthome/core/providers/repository_providers.dart';
import 'package:smarthome/core/providers/settings_provider.dart';
import 'package:smarthome/user/model/user.dart';
import 'package:smarthome/utils/exceptions.dart';

import '../../mocks/mocks.mocks.dart';

void main() {
  late MockGraphQLApiClient mockGraphQLApiClient;
  late MockUserRepository mockUserRepository;
  late MockSettingsRepository mockSettingsRepository;

  setUp(() {
    mockGraphQLApiClient = MockGraphQLApiClient();
    mockUserRepository = MockUserRepository();
    mockSettingsRepository = MockSettingsRepository();
  });

  group('AuthenticationNotifier', () {
    test('初始状态应该是 loading', () async {
      final container = ProviderContainer.test(
        overrides: [
          graphQLApiClientProvider.overrideWithValue(mockGraphQLApiClient),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          settingsServiceProvider.overrideWithValue(mockSettingsRepository),
          appConfigProvider.overrideWithValue(
            AppConfig(
              appName: 'Test',
              flavorName: 'test',
              defaultApiUrl: 'http://test.com',
              defaultAdminUrl: 'http://admin.test.com',
            ),
          ),
        ],
      );

      // 设置 settings provider 的 mock
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
      when(
        mockSettingsRepository.refreshInterval(),
      ).thenAnswer((_) async => 30);
      when(
        mockSettingsRepository.commentDescending(),
      ).thenAnswer((_) async => false);
      when(mockSettingsRepository.cookies()).thenAnswer((_) async => null);
      when(mockSettingsRepository.loginMethod()).thenAnswer((_) async => null);

      // 先初始化 settings provider
      await container.read(settingsProvider.notifier).loadSettings();

      final authState = container.read(authenticationProvider);
      expect(authState.user.isLoading, true);
    });

    test('login 成功应该更新状态', () async {
      final testUser = const User(
        username: 'testuser',
        email: 'test@example.com',
      );

      final container = ProviderContainer.test(
        overrides: [
          graphQLApiClientProvider.overrideWithValue(mockGraphQLApiClient),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          settingsServiceProvider.overrideWithValue(mockSettingsRepository),
          appConfigProvider.overrideWithValue(
            AppConfig(
              appName: 'Test',
              flavorName: 'test',
              defaultApiUrl: 'http://test.com',
              defaultAdminUrl: 'http://admin.test.com',
            ),
          ),
        ],
      );

      // 设置 mock 行为
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
      when(
        mockSettingsRepository.refreshInterval(),
      ).thenAnswer((_) async => 30);
      when(
        mockSettingsRepository.commentDescending(),
      ).thenAnswer((_) async => false);
      when(mockSettingsRepository.cookies()).thenAnswer((_) async => null);
      when(mockSettingsRepository.loginMethod()).thenAnswer((_) async => null);
      when(
        mockSettingsRepository.updateLoginUser(any),
      ).thenAnswer((_) async => {});

      when(
        mockGraphQLApiClient.login('testuser', 'password'),
      ).thenAnswer((_) async => testUser);

      // 初始化 settings
      await container.read(settingsProvider.notifier).loadSettings();

      // 执行登录
      await container
          .read(authenticationProvider.notifier)
          .login('testuser', 'password');

      final authState = container.read(authenticationProvider);
      expect(authState.user.hasValue, true);
      expect(authState.user.value, testUser);
      expect(authState.isLoading, false);
      expect(authState.errorMessage, null);

      // 验证 updateLoginUser 被调用
      verify(mockSettingsRepository.updateLoginUser(testUser)).called(1);
    });

    test('login 失败应该设置错误消息', () async {
      final container = ProviderContainer.test(
        overrides: [
          graphQLApiClientProvider.overrideWithValue(mockGraphQLApiClient),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          settingsServiceProvider.overrideWithValue(mockSettingsRepository),
          appConfigProvider.overrideWithValue(
            AppConfig(
              appName: 'Test',
              flavorName: 'test',
              defaultApiUrl: 'http://test.com',
              defaultAdminUrl: 'http://admin.test.com',
            ),
          ),
        ],
      );

      // 设置 mock 行为
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
      when(
        mockSettingsRepository.refreshInterval(),
      ).thenAnswer((_) async => 30);
      when(
        mockSettingsRepository.commentDescending(),
      ).thenAnswer((_) async => false);
      when(mockSettingsRepository.cookies()).thenAnswer((_) async => null);
      when(mockSettingsRepository.loginMethod()).thenAnswer((_) async => null);

      when(
        mockGraphQLApiClient.login('testuser', 'wrongpassword'),
      ).thenThrow(MyException('用户名或密码错误'));

      // 初始化 settings
      await container.read(settingsProvider.notifier).loadSettings();

      // 执行登录
      await container
          .read(authenticationProvider.notifier)
          .login('testuser', 'wrongpassword');

      final authState = container.read(authenticationProvider);
      expect(authState.user.hasValue, true);
      expect(authState.user.value, null);
      expect(authState.isLoading, false);
      expect(authState.errorMessage, '用户名或密码错误');
    });

    test('logout 应该清除用户状态', () async {
      final testUser = const User(
        username: 'testuser',
        email: 'test@example.com',
      );

      final container = ProviderContainer.test(
        overrides: [
          graphQLApiClientProvider.overrideWithValue(mockGraphQLApiClient),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          settingsServiceProvider.overrideWithValue(mockSettingsRepository),
          appConfigProvider.overrideWithValue(
            AppConfig(
              appName: 'Test',
              flavorName: 'test',
              defaultApiUrl: 'http://test.com',
              defaultAdminUrl: 'http://admin.test.com',
            ),
          ),
        ],
      );

      // 设置 mock 行为
      when(
        mockSettingsRepository.loginUser(),
      ).thenAnswer((_) async => testUser);
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
      when(
        mockSettingsRepository.refreshInterval(),
      ).thenAnswer((_) async => 30);
      when(
        mockSettingsRepository.commentDescending(),
      ).thenAnswer((_) async => false);
      when(mockSettingsRepository.cookies()).thenAnswer((_) async => null);
      when(mockSettingsRepository.loginMethod()).thenAnswer((_) async => null);
      when(
        mockSettingsRepository.updateLoginUser(any),
      ).thenAnswer((_) async => {});

      when(mockUserRepository.currentUser()).thenAnswer((_) async => testUser);
      when(mockGraphQLApiClient.logout()).thenAnswer((_) async => true);

      // 初始化 settings
      await container.read(settingsProvider.notifier).loadSettings();

      // 等待认证检查完成
      await Future.delayed(const Duration(milliseconds: 100));

      // 执行登出
      await container.read(authenticationProvider.notifier).logout();

      final authState = container.read(authenticationProvider);
      expect(authState.user.hasValue, true);
      expect(authState.user.value, null);
      expect(authState.errorMessage, '已登出');

      // 验证 updateLoginUser 被调用
      verify(mockSettingsRepository.updateLoginUser(null)).called(1);
    });

    test('currentUserProvider 应该返回当前用户', () async {
      final testUser = const User(
        username: 'testuser',
        email: 'test@example.com',
      );

      final container = ProviderContainer.test(
        overrides: [
          graphQLApiClientProvider.overrideWithValue(mockGraphQLApiClient),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          settingsServiceProvider.overrideWithValue(mockSettingsRepository),
          appConfigProvider.overrideWithValue(
            AppConfig(
              appName: 'Test',
              flavorName: 'test',
              defaultApiUrl: 'http://test.com',
              defaultAdminUrl: 'http://admin.test.com',
            ),
          ),
        ],
      );

      // 设置 mock 行为
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
      when(
        mockSettingsRepository.refreshInterval(),
      ).thenAnswer((_) async => 30);
      when(
        mockSettingsRepository.commentDescending(),
      ).thenAnswer((_) async => false);
      when(mockSettingsRepository.cookies()).thenAnswer((_) async => null);
      when(mockSettingsRepository.loginMethod()).thenAnswer((_) async => null);
      when(
        mockSettingsRepository.updateLoginUser(any),
      ).thenAnswer((_) async => {});

      when(
        mockGraphQLApiClient.login('testuser', 'password'),
      ).thenAnswer((_) async => testUser);

      // 初始化 settings
      await container.read(settingsProvider.notifier).loadSettings();

      // 登录前应该返回 null
      expect(container.read(currentUserProvider), null);

      // 执行登录
      await container
          .read(authenticationProvider.notifier)
          .login('testuser', 'password');

      // 登录后应该返回用户
      expect(container.read(currentUserProvider), testUser);
    });

    test('isLoggedInProvider 应该返回登录状态', () async {
      final testUser = const User(
        username: 'testuser',
        email: 'test@example.com',
      );

      final container = ProviderContainer.test(
        overrides: [
          graphQLApiClientProvider.overrideWithValue(mockGraphQLApiClient),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          settingsServiceProvider.overrideWithValue(mockSettingsRepository),
          appConfigProvider.overrideWithValue(
            AppConfig(
              appName: 'Test',
              flavorName: 'test',
              defaultApiUrl: 'http://test.com',
              defaultAdminUrl: 'http://admin.test.com',
            ),
          ),
        ],
      );

      // 设置 mock 行为
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
      when(
        mockSettingsRepository.refreshInterval(),
      ).thenAnswer((_) async => 30);
      when(
        mockSettingsRepository.commentDescending(),
      ).thenAnswer((_) async => false);
      when(mockSettingsRepository.cookies()).thenAnswer((_) async => null);
      when(mockSettingsRepository.loginMethod()).thenAnswer((_) async => null);
      when(
        mockSettingsRepository.updateLoginUser(any),
      ).thenAnswer((_) async => {});

      when(
        mockGraphQLApiClient.login('testuser', 'password'),
      ).thenAnswer((_) async => testUser);

      // 初始化 settings
      await container.read(settingsProvider.notifier).loadSettings();

      // 登录前应该返回 false
      expect(container.read(isLoggedInProvider), false);

      // 执行登录
      await container
          .read(authenticationProvider.notifier)
          .login('testuser', 'password');

      // 登录后应该返回 true
      expect(container.read(isLoggedInProvider), true);
    });
  });
}
