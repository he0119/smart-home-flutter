import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/providers/item_detail_provider.dart';
import 'package:smarthome/utils/exceptions.dart';

import '../../helpers/provider_test_utils.dart';
import '../../helpers/storage_test_utils.dart';
import '../../mocks/mocks.mocks.dart';

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  late MockStorageRepository mockStorageRepository;
  late ProviderContainer container;

  setUp(() {
    mockStorageRepository = MockStorageRepository();
    container = ProviderContainer(
      overrides: [
        storageRepositoryProvider.overrideWithValue(mockStorageRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('build returns item detail', () async {
    when(
      mockStorageRepository.item(id: 'item-1', cache: true),
    ).thenAnswer((_) async => buildItem(id: 'item-1'));

    final item = await container.read(itemDetailProvider('item-1').future);
    expect(item.id, 'item-1');
  });

  test('refresh fetches latest data', () async {
    when(
      mockStorageRepository.item(id: 'item-1', cache: true),
    ).thenAnswer((_) async => buildItem(id: 'item-1'));
    when(
      mockStorageRepository.item(id: 'item-1', cache: false),
    ).thenAnswer((_) async => buildItem(id: 'item-1'));

    final provider = itemDetailProvider('item-1');
    await container.read(provider.future);

    await container.read(provider.notifier).refresh();

    verify(mockStorageRepository.item(id: 'item-1', cache: false)).called(1);
  });

  test('emits error state when item missing', () async {
    when(
      mockStorageRepository.item(id: 'missing', cache: true),
    ).thenAnswer((_) async => null);

    final provider = itemDetailProvider('missing');
    keepProviderAlive(container, provider);

    container.read(provider);
    await _flush();

    final state = container.read(provider);
    expect(state.hasError, true);
    expect(state.error, isA<MyException>());
  });
}
