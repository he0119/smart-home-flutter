import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/providers/item_type_items_provider.dart';
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

  test('加载第一页后是 success', () async {
    when(mockStorageRepository.recentlyEditedItems(cache: true)).thenAnswer(
      (_) async => Tuple2(<Item>[
        buildItem(id: 'a'),
        buildItem(id: 'b'),
      ], const PageInfo(hasNextPage: false)),
    );

    final provider = itemTypeItemsProvider(ItemType.recentlyEdited);
    keepProviderAlive(container, provider);
    container.read(provider);
    await _flush();

    final state = container.read(provider);
    expect(state.status, ItemTypeItemsStatus.success);
    expect(state.items.map((item) => item.id), ['a', 'b']);
    expect(state.hasReachedMax, isTrue);
  });

  test('还有下一页时可以加载更多并追加', () async {
    when(mockStorageRepository.recentlyEditedItems(cache: true)).thenAnswer(
      (_) async => Tuple2(<Item>[
        buildItem(id: 'a'),
      ], const PageInfo(hasNextPage: true, endCursor: 'cursor-1')),
    );
    when(
      mockStorageRepository.recentlyEditedItems(
        after: 'cursor-1',
        cache: false,
      ),
    ).thenAnswer(
      (_) async => Tuple2(<Item>[
        buildItem(id: 'b'),
      ], const PageInfo(hasNextPage: false)),
    );

    final provider = itemTypeItemsProvider(ItemType.recentlyEdited);
    keepProviderAlive(container, provider);
    container.read(provider);
    await _flush();

    await container.read(provider.notifier).fetchMore();
    await _flush();

    final state = container.read(provider);
    expect(state.items.map((item) => item.id), ['a', 'b']);
    expect(state.hasReachedMax, isTrue);
  });

  test('仓库报错时进入 failure', () async {
    when(
      mockStorageRepository.expiredItems(cache: true),
    ).thenThrow(const MyException('网络异常'));

    final provider = itemTypeItemsProvider(ItemType.expired);
    keepProviderAlive(container, provider);
    container.read(provider);
    await _flush();

    final state = container.read(provider);
    expect(state.status, ItemTypeItemsStatus.failure);
    expect(state.errorMessage, '网络异常');
  });
}
