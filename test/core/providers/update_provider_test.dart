import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/utils/exceptions.dart';
import 'package:version/version.dart';

import '../../mocks/mocks.mocks.dart';

void main() {
  late MockVersionRepository mockVersionRepository;
  late ProviderContainer container;

  setUp(() {
    mockVersionRepository = MockVersionRepository();
    Update.debugIsAndroid = true;
    when(mockVersionRepository.needUpdate()).thenAnswer((_) async => false);
    container = ProviderContainer.test(
      overrides: [
        versionRepositoryProvider.overrideWithValue(mockVersionRepository),
      ],
    );
  });

  tearDown(() {
    Update.debugIsAndroid = null;
    container.dispose();
  });

  test(
    'checkUpdate sets update info when a new version is available',
    () async {
      when(mockVersionRepository.needUpdate()).thenAnswer((_) async => true);
      when(
        mockVersionRepository.updateUrl(),
      ).thenAnswer((_) async => 'https://example.com/app.apk');
      when(
        mockVersionRepository.onlineVersion,
      ).thenAnswer((_) async => Version.parse('2.0.0'));

      await container.read(updateProvider.notifier).checkUpdate();

      final state = container.read(updateProvider);
      expect(state.needUpdate, true);
      expect(state.url, 'https://example.com/app.apk');
      expect(state.version, Version.parse('2.0.0'));
      expect(state.errorMessage, isNull);
    },
  );

  test('checkUpdate sets state to not needing update when latest', () async {
    when(mockVersionRepository.needUpdate()).thenAnswer((_) async => false);

    await container.read(updateProvider.notifier).checkUpdate();

    final state = container.read(updateProvider);
    expect(state.needUpdate, false);
    expect(state.url, isNull);
    expect(state.version, isNull);
  });

  test('checkUpdate captures repository errors', () async {
    when(mockVersionRepository.needUpdate()).thenThrow(MyException('网络异常'));

    await container.read(updateProvider.notifier).checkUpdate();

    final state = container.read(updateProvider);
    expect(state.errorMessage, '网络异常');
  });

  test('clearError removes existing error message', () {
    final notifier = container.read(updateProvider.notifier);
    notifier.state = const UpdateInfo(errorMessage: 'error');

    notifier.clearError();

    expect(container.read(updateProvider).errorMessage, isNull);
  });
}
