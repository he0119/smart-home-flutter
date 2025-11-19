import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/providers/storage_home_provider.dart';
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

  test('home page data is populated on start', () async {
    when(mockStorageRepository.homePage(cache: true)).thenAnswer(
      (_) async => {
        'recentlyCreatedItems': [buildItem(id: 'created')],
        'recentlyEditedItems': [buildItem(id: 'edited')],
        'expiredItems': [buildItem(id: 'expired')],
        'nearExpiredItems': [buildItem(id: 'near')],
      },
    );

    keepProviderAlive(container, storageHomeProvider);
    container.read(storageHomeProvider);
    await _flush();

    final state = container.read(storageHomeProvider);
    expect(state.status, StorageHomeStatus.success);
    expect(state.recentlyCreatedItems, isNotEmpty);
    expect(state.recentlyEditedItems, isNotEmpty);
  });

  test('fetch with specific item type loads corresponding data', () async {
    when(mockStorageRepository.homePage(cache: true)).thenAnswer(
      (_) async => {
        'recentlyCreatedItems': <Item>[],
        'recentlyEditedItems': <Item>[],
        'expiredItems': <Item>[],
        'nearExpiredItems': <Item>[],
      },
    );
    when(mockStorageRepository.recentlyCreatedItems(cache: false)).thenAnswer(
      (_) async => Tuple2([buildItem(id: 'created')], buildPageInfo()),
    );

    keepProviderAlive(container, storageHomeProvider);
    container.read(storageHomeProvider);
    await _flush();

    await container
        .read(storageHomeProvider.notifier)
        .fetch(itemType: ItemType.recentlyCreated, cache: false);

    final state = container.read(storageHomeProvider);
    expect(state.itemType, ItemType.recentlyCreated);
    expect(state.recentlyCreatedItems?.first.id, 'created');
  });

  test('fetch handles repository errors', () async {
    when(mockStorageRepository.homePage(cache: true)).thenAnswer(
      (_) async => {
        'recentlyCreatedItems': <Item>[],
        'recentlyEditedItems': <Item>[],
        'expiredItems': <Item>[],
        'nearExpiredItems': <Item>[],
      },
    );
    keepProviderAlive(container, storageHomeProvider);
    container.read(storageHomeProvider);
    await _flush();

    when(
      mockStorageRepository.expiredItems(cache: false),
    ).thenThrow(MyException('获取失败'));

    await container
        .read(storageHomeProvider.notifier)
        .fetch(itemType: ItemType.expired, cache: false);

    final state = container.read(storageHomeProvider);
    expect(state.status, StorageHomeStatus.failure);
    expect(state.errorMessage, '获取失败');
  });

  test('fetch appends next page results when available', () async {
    when(mockStorageRepository.homePage(cache: true)).thenAnswer(
      (_) async => {
        'recentlyCreatedItems': <Item>[],
        'recentlyEditedItems': <Item>[],
        'expiredItems': <Item>[],
        'nearExpiredItems': <Item>[],
      },
    );
    when(
      mockStorageRepository.expiredItems(cache: false, after: 'cursor-1'),
    ).thenAnswer(
      (_) async => Tuple2([buildItem(id: 'item-2')], buildPageInfo()),
    );

    keepProviderAlive(container, storageHomeProvider);
    final notifier = container.read(storageHomeProvider.notifier);
    await _flush();
    notifier.state = StorageHomeState(
      status: StorageHomeStatus.success,
      itemType: ItemType.expired,
      expiredItems: [buildItem(id: 'item-1')],
      pageInfo: buildPageInfo(hasNextPage: true, endCursor: 'cursor-1'),
    );

    await notifier.fetch(itemType: ItemType.expired, cache: true);

    final state = container.read(storageHomeProvider);
    expect(state.expiredItems?.map((e) => e.id), ['item-1', 'item-2']);
  });
}
