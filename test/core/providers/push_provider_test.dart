import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/exceptions.dart';

import '../../helpers/provider_test_utils.dart';
import '../../mocks/mocks.mocks.dart';

void main() {
  late MockPushRepository mockPushRepository;
  late MockSettingsRepository mockSettingsRepository;
  late ProviderContainer container;

  setUp(() {
    mockPushRepository = MockPushRepository();
    mockSettingsRepository = MockSettingsRepository();
    stubDefaultSettingsRepository(
      mockSettingsRepository,
      miPushRegId: 'cached-reg-id',
    );
    when(
      mockSettingsRepository.updateMiPushRegId(any),
    ).thenAnswer((_) async => {});

    container = ProviderContainer.test(
      overrides: [
        appConfigProvider.overrideWithValue(createTestAppConfig()),
        settingsRepositoryProvider.overrideWithValue(mockSettingsRepository),
        pushRepositoryProvider.overrideWithValue(mockPushRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Future<void> loadSettings() async {
    await initializeSettings(container, mockSettingsRepository);
  }

  test('updatePush reuses cached value when regId is unchanged', () async {
    await loadSettings();

    await container.read(pushProvider.notifier).updatePush('cached-reg-id');

    final state = container.read(pushProvider);
    expect(state.localRegId, 'cached-reg-id');
    expect(state.isLoading, false);
    verifyNever(mockPushRepository.updateMiPush(regId: anyNamed('regId')));
  });

  test('updatePush uploads new regId when changed', () async {
    when(
      mockPushRepository.updateMiPush(regId: 'new-reg-id'),
    ).thenAnswer((_) async => MiPush(regId: 'server-reg-id'));
    await loadSettings();

    await container.read(pushProvider.notifier).updatePush('new-reg-id');

    final state = container.read(pushProvider);
    expect(state.localRegId, 'new-reg-id');
    expect(state.serverRegId, 'server-reg-id');
    expect(state.isLoading, false);
    verify(mockPushRepository.updateMiPush(regId: 'new-reg-id')).called(1);
    verify(mockSettingsRepository.updateMiPushRegId('new-reg-id')).called(1);
  });

  test('updatePush stores error message when upload fails', () async {
    when(
      mockPushRepository.updateMiPush(regId: anyNamed('regId')),
    ).thenThrow(MyException('上传失败'));
    await loadSettings();

    await container.read(pushProvider.notifier).updatePush('error-reg-id');

    final state = container.read(pushProvider);
    expect(state.errorMessage, '上传失败');
    expect(state.isLoading, false);
  });

  test('refreshPush keeps state in sync when regId matches server', () async {
    when(
      mockPushRepository.miPush(),
    ).thenAnswer((_) async => MiPush(regId: 'cached-reg-id'));
    await loadSettings();

    await container.read(pushProvider.notifier).refreshPush('cached-reg-id');

    final state = container.read(pushProvider);
    expect(state.localRegId, 'cached-reg-id');
    expect(state.serverRegId, 'cached-reg-id');
    verifyNever(mockPushRepository.updateMiPush(regId: anyNamed('regId')));
  });

  test('refreshPush uploads when server regId is outdated', () async {
    when(
      mockPushRepository.miPush(),
    ).thenAnswer((_) async => MiPush(regId: 'remote-reg-id'));
    when(
      mockPushRepository.updateMiPush(regId: 'fresh-reg-id'),
    ).thenAnswer((_) async => MiPush(regId: 'fresh-reg-id'));
    await loadSettings();

    await container.read(pushProvider.notifier).refreshPush('fresh-reg-id');

    verify(mockPushRepository.updateMiPush(regId: 'fresh-reg-id')).called(1);
  });

  test('refreshPush uploads when server binding is missing', () async {
    when(mockPushRepository.miPush()).thenThrow(MyException('推送未绑定'));
    when(
      mockPushRepository.updateMiPush(regId: 'fresh-reg-id'),
    ).thenAnswer((_) async => MiPush(regId: 'fresh-reg-id'));
    await loadSettings();

    await container.read(pushProvider.notifier).refreshPush('fresh-reg-id');

    verify(mockPushRepository.updateMiPush(regId: 'fresh-reg-id')).called(1);
  });

  test('refreshPush surfaces unexpected errors', () async {
    when(mockPushRepository.miPush()).thenThrow(MyException('服务器错误'));
    await loadSettings();

    await container.read(pushProvider.notifier).refreshPush('fresh-reg-id');

    final state = container.read(pushProvider);
    expect(state.errorMessage, '服务器错误');
  });

  test('clearError removes stored error message', () async {
    await loadSettings();
    final notifier = container.read(pushProvider.notifier);
    notifier.state = const PushInfo(errorMessage: 'error');

    notifier.clearError();

    expect(container.read(pushProvider).errorMessage, isNull);
  });
}
