import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/providers/recycle_bin_provider.dart';
import 'package:smarthome/utils/exceptions.dart';
import 'package:tuple/tuple.dart';

import '../../helpers/provider_test_utils.dart';
import '../../helpers/storage_test_utils.dart';
import '../../mocks/mocks.mocks.dart';

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  late MockStorageRepository mockStorageRepository;
  late ProviderContainer container;

  setUp(() {
    mockStorageRepository = MockStorageRepository();
    container = ProviderContainer.test(
      overrides: [
        storageRepositoryProvider.overrideWithValue(mockStorageRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('loads deleted items on start', () async {
    when(
      mockStorageRepository.deletedItems(cache: true),
    ).thenAnswer((_) async => Tuple2([buildItem()], buildPageInfo()));

    keepProviderAlive(container, recycleBinProvider);
    container.read(recycleBinProvider);
    await _flush();

    final state = container.read(recycleBinProvider);
    expect(state.status, RecycleBinStatus.success);
    expect(state.items, hasLength(1));
  });

  test('fetch handles pagination correctly', () async {
    when(mockStorageRepository.deletedItems(cache: true)).thenAnswer(
      (_) async => Tuple2([
        buildItem(id: 'item-1'),
      ], buildPageInfo(hasNextPage: true, endCursor: 'cursor-1')),
    );
    when(
      mockStorageRepository.deletedItems(cache: false, after: 'cursor-1'),
    ).thenAnswer(
      (_) async => Tuple2([buildItem(id: 'item-2')], buildPageInfo()),
    );

    keepProviderAlive(container, recycleBinProvider);
    container.read(recycleBinProvider);
    await _flush();
    await container.read(recycleBinProvider.notifier).fetch(cache: true);

    final state = container.read(recycleBinProvider);
    expect(state.items.map((e) => e.id), ['item-1', 'item-2']);
  });

  test('fetch(cache: false) surfaces repository errors', () async {
    when(
      mockStorageRepository.deletedItems(cache: true),
    ).thenAnswer((_) async => Tuple2([buildItem()], buildPageInfo()));
    keepProviderAlive(container, recycleBinProvider);
    container.read(recycleBinProvider);
    await _flush();

    when(
      mockStorageRepository.deletedItems(cache: false),
    ).thenThrow(MyException('拉取失败'));

    await container.read(recycleBinProvider.notifier).fetch(cache: false);

    final state = container.read(recycleBinProvider);
    expect(state.status, RecycleBinStatus.failure);
    expect(state.errorMessage, '拉取失败');
  });
}
