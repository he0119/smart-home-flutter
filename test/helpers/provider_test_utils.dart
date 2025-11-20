import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/user/model/user.dart';

import '../mocks/mocks.mocks.dart';

AppConfig createTestAppConfig() => AppConfig(
  appName: 'Test',
  flavorName: 'test',
  defaultApiUrl: 'https://api.test.dev',
  defaultAdminUrl: 'https://admin.test.dev',
  defaultBlogUrl: 'https://blog.test.dev',
);

void stubDefaultSettingsRepository(
  MockSettingsRepository settingsRepository, {
  User? loginUser,
  ThemeMode themeMode = ThemeMode.system,
  AppTab defaultPage = AppTab.storage,
  String? apiUrl,
  String? adminUrl,
  String? blogUrl,
  String? blogAdminUrl,
  String? miPushAppId,
  String? miPushAppKey,
  String? miPushRegId,
  int refreshInterval = 30,
  bool commentDescending = false,
  String? cookies,
  String? loginMethod,
}) {
  when(settingsRepository.loginUser()).thenAnswer((_) async => loginUser);
  when(settingsRepository.themeMode()).thenAnswer((_) async => themeMode);
  when(settingsRepository.defaultPage()).thenAnswer((_) async => defaultPage);
  when(settingsRepository.apiUrl()).thenAnswer((_) async => apiUrl);
  when(settingsRepository.adminUrl()).thenAnswer((_) async => adminUrl);
  when(settingsRepository.blogUrl()).thenAnswer((_) async => blogUrl);
  when(settingsRepository.blogAdminUrl()).thenAnswer((_) async => blogAdminUrl);
  when(settingsRepository.miPushAppId()).thenAnswer((_) async => miPushAppId);
  when(settingsRepository.miPushAppKey()).thenAnswer((_) async => miPushAppKey);
  when(settingsRepository.miPushRegId()).thenAnswer((_) async => miPushRegId);
  when(
    settingsRepository.refreshInterval(),
  ).thenAnswer((_) async => refreshInterval);
  when(
    settingsRepository.commentDescending(),
  ).thenAnswer((_) async => commentDescending);
  when(settingsRepository.cookies()).thenAnswer((_) async => cookies);
  when(settingsRepository.loginMethod()).thenAnswer((_) async => loginMethod);
}

Future<void> initializeSettings(
  ProviderContainer container,
  MockSettingsRepository settingsRepository,
) async {
  await container.read(settingsProvider.notifier).loadSettings();
}

void keepProviderAlive(ProviderContainer container, dynamic provider) {
  final subscription = container.listen<dynamic>(
    provider,
    (_, _) {},
    fireImmediately: true,
  );
  addTearDown(subscription.close);
}
