import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/providers/storage_detail_provider.dart';
import 'package:smarthome/utils/exceptions.dart';
import 'package:tuple/tuple.dart';

import '../../helpers/provider_test_utils.dart';
import '../../helpers/storage_test_utils.dart';
import '../../mocks/mocks.mocks.dart';

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  late MockStorageRepository mockStorageRepository;

  setUp(() {
    mockStorageRepository = MockStorageRepository();
  });

  test('loads root storage when id is empty', () async {
    when(mockStorageRepository.rootStorage(cache: true)).thenAnswer(
      (_) async => Tuple2([buildStorage(id: 'child')], buildPageInfo()),
    );

    final container = ProviderContainer.test(
      overrides: [
        storageRepositoryProvider.overrideWithValue(mockStorageRepository),
      ],
    );

    keepProviderAlive(container, storageDetailProvider(''));
    container.read(storageDetailProvider(''));
    await _flush();

    final state = container.read(storageDetailProvider(''));
    expect(state.status, StorageDetailStatus.success);
    expect(state.storage.children, isNotEmpty);
    container.dispose();
  });

  test('loads storage detail for non-root id', () async {
    when(
      mockStorageRepository.storage(id: 'storage-123', cache: true),
    ).thenAnswer(
      (_) async => Tuple3(
        buildStorage(
          id: 'storage-123',
          children: [buildStorage(id: 'child-1')],
          items: [buildItem(id: 'item-1')],
        ),
        buildPageInfo(hasNextPage: true, endCursor: 'storage-cursor'),
        buildPageInfo(hasNextPage: true, endCursor: 'item-cursor'),
      ),
    );
    when(
      mockStorageRepository.storage(
        id: 'storage-123',
        cache: false,
        storageCursor: 'storage-cursor',
        itemCursor: 'item-cursor',
      ),
    ).thenAnswer(
      (_) async => Tuple3(
        buildStorage(
          id: 'storage-123',
          children: [buildStorage(id: 'child-2')],
          items: [buildItem(id: 'item-2')],
        ),
        buildPageInfo(endCursor: 'storage-cursor-2'),
        buildPageInfo(endCursor: 'item-cursor-2'),
      ),
    );

    final container = ProviderContainer.test(
      overrides: [
        storageRepositoryProvider.overrideWithValue(mockStorageRepository),
      ],
    );

    final provider = storageDetailProvider('storage-123');
    keepProviderAlive(container, provider);
    container.read(provider);
    await _flush();

    await container.read(provider.notifier).fetchMore();

    final state = container.read(provider);
    expect(state.storage.children?.length, 2);
    expect(state.storage.items?.length, 2);
    container.dispose();
  });

  test('handles missing storage gracefully', () async {
    when(
      mockStorageRepository.storage(id: 'missing', cache: true),
    ).thenAnswer((_) async => null);

    final container = ProviderContainer.test(
      overrides: [
        storageRepositoryProvider.overrideWithValue(mockStorageRepository),
      ],
    );

    keepProviderAlive(container, storageDetailProvider('missing'));
    container.read(storageDetailProvider('missing'));
    await _flush();

    final state = container.read(storageDetailProvider('missing'));
    expect(state.status, StorageDetailStatus.failure);
    expect(state.errorMessage, isNotEmpty);
    container.dispose();
  });

  test('refresh propagates repository errors', () async {
    when(
      mockStorageRepository.storage(id: 'storage-1', cache: true),
    ).thenAnswer(
      (_) async => Tuple3(
        buildStorage(id: 'storage-1', children: [], items: []),
        buildPageInfo(),
        buildPageInfo(),
      ),
    );
    when(
      mockStorageRepository.storage(id: 'storage-1', cache: false),
    ).thenThrow(MyException('刷新失败'));

    final container = ProviderContainer.test(
      overrides: [
        storageRepositoryProvider.overrideWithValue(mockStorageRepository),
      ],
    );

    final provider = storageDetailProvider('storage-1');
    keepProviderAlive(container, provider);
    container.read(provider);
    await _flush();

    container.read(provider.notifier).refresh();
    await _flush();

    final state = container.read(provider);
    expect(state.status, StorageDetailStatus.failure);
    expect(state.errorMessage, '刷新失败');
    container.dispose();
  });
}
