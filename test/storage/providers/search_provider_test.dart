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
  late MockSettingsRepository mockSettingsRepository;
  late ProviderContainer container;

  setUp(() {
    mockStorageRepository = MockStorageRepository();
    mockSettingsRepository = MockSettingsRepository();
    when(mockSettingsRepository.searchHistory()).thenAnswer((_) async => []);
    when(
      mockSettingsRepository.updateSearchHistory(any),
    ).thenAnswer((_) async {});
    when(mockSettingsRepository.clearSearchHistory()).thenAnswer((_) async {});
    container = ProviderContainer.test(
      overrides: [
        storageRepositoryProvider.overrideWithValue(mockStorageRepository),
        settingsRepositoryProvider.overrideWithValue(mockSettingsRepository),
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
    expect(state.history, isEmpty);
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

  test('loadHistory reads saved search history', () async {
    when(
      mockSettingsRepository.searchHistory(),
    ).thenAnswer((_) async => ['keyboard', 'router']);

    await container.read(searchProvider.notifier).loadHistory();

    expect(container.read(searchProvider).history, ['keyboard', 'router']);
  });

  test('search saves successful terms to history', () async {
    when(
      mockStorageRepository.search(
        any,
        isDeleted: anyNamed('isDeleted'),
        missingStorage: anyNamed('missingStorage'),
      ),
    ).thenAnswer((_) async => const Tuple2([], []));

    await container.read(searchProvider.notifier).loadHistory();
    await container.read(searchProvider.notifier).search('keyboard');

    expect(container.read(searchProvider).history, ['keyboard']);
    verify(mockSettingsRepository.updateSearchHistory(['keyboard'])).called(1);
  });

  test('search moves repeated terms to the front', () async {
    when(
      mockSettingsRepository.searchHistory(),
    ).thenAnswer((_) async => ['router', 'keyboard']);
    when(
      mockStorageRepository.search(
        any,
        isDeleted: anyNamed('isDeleted'),
        missingStorage: anyNamed('missingStorage'),
      ),
    ).thenAnswer((_) async => const Tuple2([], []));

    await container.read(searchProvider.notifier).loadHistory();
    await container.read(searchProvider.notifier).search('keyboard');

    expect(container.read(searchProvider).history, ['keyboard', 'router']);
    verify(
      mockSettingsRepository.updateSearchHistory(['keyboard', 'router']),
    ).called(1);
  });

  test('removeHistory deletes a single saved term', () async {
    when(
      mockSettingsRepository.searchHistory(),
    ).thenAnswer((_) async => ['router', 'keyboard']);

    await container.read(searchProvider.notifier).loadHistory();
    await container.read(searchProvider.notifier).removeHistory('router');

    expect(container.read(searchProvider).history, ['keyboard']);
    verify(mockSettingsRepository.updateSearchHistory(['keyboard'])).called(1);
  });

  test('clearHistory removes all saved terms', () async {
    when(
      mockSettingsRepository.searchHistory(),
    ).thenAnswer((_) async => ['router']);

    await container.read(searchProvider.notifier).loadHistory();
    await container.read(searchProvider.notifier).clearHistory();

    expect(container.read(searchProvider).history, isEmpty);
    verify(mockSettingsRepository.clearSearchHistory()).called(1);
  });
}
