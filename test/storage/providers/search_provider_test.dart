import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/providers/search_provider.dart';
import 'package:smarthome/utils/exceptions.dart';
import 'package:tuple/tuple.dart';

import '../../helpers/storage_test_utils.dart';
import '../../mocks/mocks.mocks.dart';

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

  test('search fetches items and storages', () async {
    when(
      mockStorageRepository.search(
        any,
        isDeleted: anyNamed('isDeleted'),
        missingStorage: anyNamed('missingStorage'),
      ),
    ).thenAnswer(
      (_) async =>
          Tuple2([buildItem(id: 'item-1')], [buildStorage(id: 'storage-1')]),
    );

    await container
        .read(searchProvider.notifier)
        .search('keyboard', isDeleted: false, missingStorage: false);

    final state = container.read(searchProvider);
    expect(state.status, SearchStatus.success);
    expect(state.items.single.id, 'item-1');
    expect(state.storages.single.id, 'storage-1');
    expect(state.term, 'keyboard');
  });

  test('search clears state when key is empty', () async {
    container.read(searchProvider.notifier).state = SearchState(
      status: SearchStatus.success,
      items: [buildItem()],
    );

    await container.read(searchProvider.notifier).search('');

    final state = container.read(searchProvider);
    expect(state.status, SearchStatus.initial);
    expect(state.items, isEmpty);
  });

  test('search surfaces repository errors', () async {
    when(
      mockStorageRepository.search(
        any,
        isDeleted: anyNamed('isDeleted'),
        missingStorage: anyNamed('missingStorage'),
      ),
    ).thenThrow(MyException('搜索失败'));

    await container.read(searchProvider.notifier).search('router');

    final state = container.read(searchProvider);
    expect(state.status, SearchStatus.failure);
    expect(state.errorMessage, '搜索失败');
  });
}
