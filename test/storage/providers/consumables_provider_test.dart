import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/providers/consumables_provider.dart';
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

  test('loads consumables on initialization', () async {
    when(
      mockStorageRepository.consumables(cache: true),
    ).thenAnswer((_) async => Tuple2([buildItem()], buildPageInfo()));

    keepProviderAlive(container, consumablesProvider);
    container.read(consumablesProvider);
    await _flush();

    final state = container.read(consumablesProvider);
    expect(state.status, ConsumablesStatus.success);
    expect(state.items, hasLength(1));
  });

  test('fetch(cache: false) refreshes and handles failures', () async {
    when(mockStorageRepository.consumables(cache: true)).thenAnswer(
      (_) async => Tuple2([buildItem(id: 'item-1')], buildPageInfo()),
    );
    keepProviderAlive(container, consumablesProvider);
    container.read(consumablesProvider);
    await _flush();

    when(
      mockStorageRepository.consumables(cache: false),
    ).thenThrow(MyException('获取耗材失败'));

    await container.read(consumablesProvider.notifier).fetch(cache: false);

    final state = container.read(consumablesProvider);
    expect(state.status, ConsumablesStatus.failure);
    expect(state.errorMessage, '获取耗材失败');
  });

  test('fetch appends next page items when cache hit is allowed', () async {
    when(mockStorageRepository.consumables(cache: true)).thenAnswer(
      (_) async => Tuple2([
        buildItem(id: 'item-1'),
      ], buildPageInfo(hasNextPage: true, endCursor: 'cursor-1')),
    );
    when(
      mockStorageRepository.consumables(cache: false, after: 'cursor-1'),
    ).thenAnswer(
      (_) async =>
          Tuple2([buildItem(id: 'item-2')], buildPageInfo(hasNextPage: false)),
    );

    keepProviderAlive(container, consumablesProvider);
    container.read(consumablesProvider);
    await _flush();
    await container.read(consumablesProvider.notifier).fetch(cache: true);

    final state = container.read(consumablesProvider);
    expect(state.items.map((e) => e.id), ['item-1', 'item-2']);
    expect(state.hasReachedMax, true);
  });
}
